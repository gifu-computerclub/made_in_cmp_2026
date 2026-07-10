extends Control
@onready var game_over_overlay: Control = %GameOverOverlay
@onready var game_over_label: Label = %GameOverLabel
@onready var back_button: Button = %BackButton
@onready var game_clear_overlay: Control = %GameClearOverlay
@onready var debug_mode_control: Control = %DebugModeControl
@onready var debug_meter: TextureProgressBar = %DebugMeter
@onready var animation_player: AnimationPlayer = $CanvasLayer2/DebugModeControl/AnimationPlayer
@onready var fps_label: Label = %FpsLabel
@onready var title_back: HBoxContainer = %TitleBack
@onready var title_back_meter: TextureProgressBar = %TitleBackMeter
@onready var title_back_label: Label = %TitleBackLabel

@export var can_debug_mode:bool = true
@export var meter_grad:Gradient
var select_dis:Discription
var long_start:bool = true
var debug_mode:bool
var _hold_time := 1.0  # 長押し判定時間（秒）
var _title_hold_time := 3.0
var _hold_timer := 0.0
var _is_button_held := false
var _toggled := false
var _meter_value:float = 0
func _process(delta: float) -> void:
	_debug_toggle(delta)
	_title_back_toggle(delta)

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
	fps_label.text = "FPS:%d"%Engine.get_frames_per_second()
	if Input.is_action_pressed("X")and can_debug_mode and title:  # 入力アクション名を設定
		_hold_timer += delta
		if _toggled == false:
			_meter_value = min(_hold_timer / _hold_time, 1.0)
		if _hold_timer >= _hold_time and not _toggled:
			debug_mode = !debug_mode
			_meter_value = 0.0
			print("Debug toggled:", debug_mode)
			_toggled = true  # 1回だけトグル
			_debug_mode_change()
	elif title and can_debug_mode:
		_hold_timer = 0.0
		_meter_value = 0.0
		_toggled = false

func _debug_mode_change() -> void:
	if debug_mode:
		debug_mode_control.visible = true
		animation_player.play("debug_mode")
	else:
		animation_player.play_backwards("debug_mode")
		await animation_player.animation_finished
		debug_mode_control.visible = false
		
func _title_back_toggle(delta:float)-> void:
	var title:Node = get_tree().get_first_node_in_group("title")
	title_back_meter.value = _meter_value*100
	if Input.is_action_pressed("X") and not title and debug_mode:  # 入力アクション名を設定
		_hold_timer += delta
		if _toggled == false:
			title_back.visible = true
			_meter_value = min(_hold_timer / _title_hold_time, 1.0)
			title_back_meter.tint_progress = _get_gradation(_meter_value)
			title_back_label.add_theme_color_override("font_color",_get_gradation(_meter_value))
			if _meter_value <=0.25:
				title_back_label.text = "タイトルに戻ります"
			elif _meter_value > 0.25 and _meter_value <= 0.5:
				title_back_label.text = "タイトルに戻ります."
			elif _meter_value > 0.5 and _meter_value <= 0.75:
				title_back_label.text = "タイトルに戻ります.."
			elif _meter_value > 0.75 and _meter_value <= 1:
				title_back_label.text = "タイトルに戻ります..."
		if _hold_timer >= _title_hold_time and not _toggled:
			get_tree().paused = false
			SceneManager.change_scene("res://titlemenu/scenes/title.tscn",{"color":Color("#FFFFFF"),"pattern":"squares"})
			_meter_value = 0.0
			title_back.visible = false
			print("Debug toggled:", debug_mode)
			_toggled = true  # 1回だけトグル
	elif not title:
		_hold_timer = 0.0
		_meter_value = 0.0
		_toggled = false
		title_back.visible = false

func _get_gradation(value:float) -> Color:
	return meter_grad.sample(value)
#endregion
