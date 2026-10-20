
class_name Enemy
extends ArielGame1Character

## インスペクターからプレイヤーを指定
@export var target_path: NodePath

## AIの設定

## 移動判断の間隔
@export var move_interval: float = 0.6

## 攻撃間隔
@export var attack_interval: float = 1.5

## プレイヤーのパンチを回避する確率
@export_range(0.0, 1.0) var dodge_chance: float = 0.65

## しゃがみの再使用待ち時間
@export var dodge_cooldown: float = 1.0

## 足元攻撃としてしゃがむ確率
@export_range(0.0, 1.0) var low_attack_chance: float = 0.3

## ランダム移動の間隔
@export var random_move_interval: float = 2.0

## ランダム移動を行う確率
@export_range(0.0, 1.0) var random_move_chance: float = 0.35

var target: ArielGame1Character

var _move_timer: float = 0.0
var _attack_timer: float = 0.0
var _dodge_timer: float = 0.0
var _random_move_timer: float = 0.0

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	super._ready()

	_rng.randomize()

	if not change_health.is_connected(_on_health_changed):
		change_health.connect(_on_health_changed)

	# インスペクターで指定されたプレイヤーを取得
	if not target_path.is_empty():
		target = get_node_or_null(target_path) as ArielGame1Character

	# 未指定なら player() を持つノードを検索
	if target == null:
		target = _find_player(get_tree().root)

	_move_timer = move_interval
	_attack_timer = attack_interval
	_dodge_timer = dodge_cooldown
	_random_move_timer = random_move_interval


func _process(delta: float) -> void:
	if health <= 0 or not is_instance_valid(target):
		return

	_move_timer -= delta
	_attack_timer -= delta
	_dodge_timer -= delta
	_random_move_timer -= delta

	# プレイヤーがパンチ中なら回避を試みる
	if _is_player_attacking() and _dodge_timer <= 0.0:
		if _rng.randf() < dodge_chance:
			_do_dodge()

	# 一定時間ごとに移動判断
	if _move_timer <= 0.0:
		_move_toward_player()
		_move_timer = move_interval

	# ランダム移動
	if _random_move_timer <= 0.0:
		if _rng.randf() < random_move_chance:
			_move_randomly()

		_random_move_timer = random_move_interval

	# 同じレーンならパンチ
	if _attack_timer <= 0.0 and _is_in_attack_range():
		_do_attack()

	# 足元攻撃としてしゃがむ
	# プレイヤーが攻撃中でなくても実行する
	if _dodge_timer <= 0.0 and not sneek_anim.is_playing():
		if _rng.randf() < low_attack_chance * delta:
			_do_low_attack()


## player() を持つキャラクターを探す
func _find_player(node: Node) -> ArielGame1Character:
	for child in node.get_children():
		if child is ArielGame1Character and child.has_method(&"player"):
			return child as ArielGame1Character

		var result := _find_player(child)
		if result != null:
			return result

	return null


## プレイヤーがパンチ中か判定
func _is_player_attacking() -> bool:
	if not is_instance_valid(target):
		return false

	return target.punch_anim.is_playing()


## プレイヤーに向かってレーン移動
func _move_toward_player() -> void:
	if punched or not is_instance_valid(target):
		return

	var lanes: Array[StringName] = [
		&"left",
		&"middle",
		&"right"
	]

	var current_lane := _get_lane_index(position.x)
	var target_lane := _get_lane_index(target.position.x)

	# 同じレーンなら移動しない
	if current_lane == target_lane:
		return

	# 隣のレーンへ1つ移動
	if current_lane < target_lane:
		current_lane += 1
	else:
		current_lane -= 1

	move(lanes[clampi(current_lane, 0, 2)])


## ランダムに別のレーンへ移動
func _move_randomly() -> void:
	if punched:
		return

	var lanes: Array[StringName] = [
		&"left",
		&"middle",
		&"right"
	]

	var current_lane := _get_lane_index(position.x)
	var choices: Array[StringName] = []

	for i in range(lanes.size()):
		if i != current_lane:
			choices.append(lanes[i])

	if choices.is_empty():
		return

	move(choices[_rng.randi_range(0, choices.size() - 1)])


## X座標からレーン番号を取得
## 左=0、中央=1、右=2
func _get_lane_index(x: float) -> int:
	if x < -0.75:
		return 0
	elif x > 0.75:
		return 2

	return 1


## プレイヤーと同じレーンなら攻撃可能
func _is_in_attack_range() -> bool:
	if not is_instance_valid(target):
		return false

	return (
		_get_lane_index(position.x)
		== _get_lane_index(target.position.x)
	)


## パンチ攻撃
func _do_attack() -> void:
	if punch_anim.is_playing():
		return

	if not _is_in_attack_range():
		return

	_attack_timer = attack_interval
	punch()


## 回避としてしゃがむ
func _do_dodge() -> void:
	if sneek_anim.is_playing():
		return

	_dodge_timer = dodge_cooldown
	sneek_anim.play(&"sneek")


## 足元攻撃としてしゃがむ
func _do_low_attack() -> void:
	if sneek_anim.is_playing():
		return

	_dodge_timer = dodge_cooldown
	sneek_anim.play(&"sneek")


## 敵判定用メソッド
func enemy() -> void:
	pass


## 体力変化時
func _on_health_changed() -> void:
	if is_instance_valid(main) and "enemy_hp" in main:
		main.enemy_hp.value = health

	if health <= 0:
		set_process(false)
		set_physics_process(false)
		GameManager.game_clear(&"クリア！")
