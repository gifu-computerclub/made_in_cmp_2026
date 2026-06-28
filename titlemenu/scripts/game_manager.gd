extends Control
@onready var game_over_overlay: Control = %GameOverOverlay
@onready var game_over_label: Label = %GameOverLabel
@onready var back_button: Button = %BackButton
@onready var game_clear_overlay: Control = %GameClearOverlay
@onready var debug_text: RichTextLabel = %DebugText
@onready var debug_meter: TextureProgressBar = %DebugMeter

@export var can_debug_mode:bool = true
var select_dis:Discription
var long_start:bool = true
var debug_mode:bool
var _hold_time := 1.0  # 長押し判定時間（秒）
var _hold_timer := 0.0
var _is_button_held := false
var _toggled := false
var _meter_value:float = 0
func _process(delta: float) -> void:
	_debug_toggle(delta)

#region ゲーム操作
func game_over() -> void:
	get_tree().paused = true
	game_over_overlay.visible = true
	game_over_overlay.position.y = -game_over_overlay.size.y
	game_over_label.rotation = 0.0
	# Tweenで降りてくる
	var tween = create_tween()
	tween.tween_property(game_over_overlay, "position:y", 0, 1.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(game_over_label, "rotation", 0.1, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await tween.finished
	await get_tree().create_timer(2.0).timeout
	SceneManager.change_scene("res://titlemenu/scenes/title.tscn")
	await SceneManager.fade_complete
	get_tree().paused = false
	game_over_overlay.visible = false


func game_clear() -> void:
	get_tree().paused = true
	game_clear_overlay.modulate.a = 0
	game_clear_overlay.visible = true
	var tween:Tween = create_tween()
	tween.tween_property(game_clear_overlay,"modulate:a",1.0,1)
	await tween.finished
	back_button.grab_focus()
	_start_button_blink()
	

func _start_button_blink() -> void:
	var button_tween:Tween = create_tween().set_loops()
	button_tween.tween_property(back_button,"modulate:a",0.3,0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	button_tween.tween_property(back_button,"modulate:a",1.0,0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_back_button_pressed() -> void:
	SceneManager.change_scene("res://titlemenu/scenes/title.tscn")
	await SceneManager.fade_complete
	get_tree().paused = false
	game_clear_overlay.visible = false
#endregion

#region デバックモード
func _debug_toggle(delta:float) -> void:
	var title:Node = get_tree().get_first_node_in_group("title")
	debug_meter.value = _meter_value*100
	if debug_mode:
		debug_text.visible=true
	else:
		debug_text.visible=false
	if Input.is_action_pressed("X")and can_debug_mode and title:  # 入力アクション名を設定
		_hold_timer += delta
		if _toggled == false:
			_meter_value = min(_hold_timer / _hold_time, 1.0)
		if _hold_timer >= _hold_time and not _toggled:
			debug_mode = !debug_mode
			_meter_value = 0.0
			print("Debug toggled:", debug_mode)
			_toggled = true  # 1回だけトグル
	else:
		_hold_timer = 0.0
		_meter_value = 0.0
		_toggled = false
#endregion
