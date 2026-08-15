@tool
@icon("res://titlemenu/assets/texture/icons/timer.svg")
class_name TimerUi
extends Control

##タイマー終了時に発行されます。
signal timeout

var ratio_time:float

##残り時間
@export var wait_time:float = 20.0:
	set(value):
		wait_time = value
		call_deferred("_editor_changed")
##シーン開始時自動で開始します。
@export  var auto_start:bool = false
##数字が残り時間に応じて色が変化します
@export var change_value_color:bool = false

##メーターの色を変えます。[code]gradation[/code]が有効の時は機能しません。
@export var meter_color:Color = Color("00ff00ff"):
	set(value):
		meter_color = value
		call_deferred("_editor_changed")
@export_group("Gradation")
##メーターを残り時間に応じて色を変化させるようにします。
@export_custom(PROPERTY_HINT_GROUP_ENABLE,"") var gradation:bool = true:
	set(value):
		gradation = value
		call_deferred("_editor_changed")
		notify_property_list_changed()
##開始時の色です。
@export var start_color:Color = Color("00ff00ff"):
	set(value):
		start_color = value
		call_deferred("_editor_changed")
##終了時の色です
@export var end_color:Color = Color("ff0000ff")
##始点と終点の代わりに細かく設定できるものを使用します。上記2つは反映されなくなります。
@export var use_custom_gradation:bool = false:
	set(value):
		use_custom_gradation = value
		call_deferred("_editor_changed")
		notify_property_list_changed()
##グラデーションを細かく設定できます。
@export var custom_gradation:Gradient


@onready var meter: TextureProgressBar = %Meter
@onready var clock: TextureProgressBar = %Clock
@onready var time_label: Label = %TimeLabel
@onready var game_timer: Timer = $GameTimer
@onready var update: Timer = $Update


func _validate_property(property: Dictionary) -> void:
	if property.name == "meter_color":
		if gradation:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "custom_gradation":
		if !use_custom_gradation:
			property.usage = PROPERTY_USAGE_NO_EDITOR
func _ready() -> void:
	if !Engine.is_editor_hint():
		game_timer.wait_time = wait_time
		ratio_time = 100.0 / wait_time
		if gradation:
			if use_custom_gradation:
				meter.tint_progress = _get_gradation(100)
			else:
				meter.tint_progress = start_color
		else:
			meter.tint_progress = meter_color
		time_label.text = str(int(wait_time))
		time_label.add_theme_color_override("font_color",Color(0,0,0))
		clock.value = wait_time *ratio_time
		if auto_start:
			start()

func _editor_changed() -> void:
	if !Engine.is_editor_hint() and not is_node_ready():
		return
	time_label.text = str(int(wait_time))
	meter.tint_progress = start_color if gradation else meter_color
func _on_update_timeout() -> void:
	var remaining_time: float = game_timer.time_left
	var ratio_now_time: float = remaining_time / wait_time
	
	#カラー
	if gradation ==  true:
		if use_custom_gradation:
			meter.tint_progress = _get_gradation((remaining_time-1)*ratio_time)
		else:
			meter.tint_progress = _get_meter_color((remaining_time-1)*ratio_time)
	elif gradation == false:
		meter.tint_progress = meter_color
	
	if change_value_color == false:
		time_label.add_theme_color_override("font_color",Color(0,0,0))
	elif change_value_color == true:
		if ratio_now_time >= 0.5:
			time_label.add_theme_color_override("font_color",Color(0,0,0))
		elif ratio_now_time < 0.5 and ratio_now_time >= 0.25:
			time_label.add_theme_color_override("font_color",Color(1,0.5,0))
		elif ratio_now_time < 0.25:
			time_label.add_theme_color_override("font_color",Color(1,0,0))
	
	clock.value = (remaining_time-1)*ratio_time
	meter.value = (remaining_time-1)*ratio_time
	time_label.text =str(int(remaining_time))

func _get_meter_color(value: float) -> Color:
	value = clamp(value, 0, 100)
	var h: float = lerp(end_color.h, start_color.h, value / 100.0)
	var s: float = lerp(end_color.s, start_color.s, value / 100.0)
	var v: float = lerp(end_color.v, start_color.v, value / 100.0)
	return Color.from_hsv(h, s, v)
func _get_gradation(value:float) -> Color:
	var t:float = inverse_lerp(0,100, value)
	if custom_gradation == null:
		custom_gradation = preload("res://template/timer/scenes/defalt_gradient.tres").duplicate()
	return custom_gradation.sample(t)

##タイマーをスタートさせます。
func start() -> void:
	game_timer.start()
	update.start()
##タイマーをストップさせます。
func stop() -> void:
	game_timer.stop()
	update.stop()
##タイマーの現在の残り時間を取得します。
func get_remiting_time() -> float:
	return game_timer.time_left

func _on_game_timer_timeout() -> void:
	timeout.emit()
