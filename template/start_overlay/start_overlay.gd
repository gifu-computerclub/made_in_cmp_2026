@tool
@icon("res://titlemenu/assets/texture/icons/start_overray.svg")
extends Control

##オーバーレイ終了時に発行
signal game_start()

##　タイトルを表示
@export var title_name:String = "タイトル":
	set(value):
		title_name = value
		_set_viwe_editor()
##　タイトルの色を変更
@export var title_color:Color = Color(0,0,1):
	set(value):
		title_color = value
		_set_viwe_editor()
## オンでアウトラインが黒に
@export var outline_color_black:bool = false:
	set(value):
		outline_color_black = value
		_set_viwe_editor()
@export_group("Title Slide")
## カウントダウン終了時タイトルを移動
@export_custom(PROPERTY_HINT_GROUP_ENABLE,"") var title_slide:bool = true:
	set(value):
		title_slide = value
		_set_viwe_editor()
## 移動後のポジション
@export var after_position:Vector2 = Vector2(537,103):
	set(value):
		after_position = value
		_set_viwe_editor()
## 移動後の文字サイズ
@export var after_size:int = 64:
	set(value):
		after_size = value
		_set_viwe_editor()
## 移動後のアウトラインサイズ
@export var after_outline:int = 20:
	set(value):
		after_outline = value
		_set_viwe_editor()

@export_group("")
##　移動後を映す
@export var test:bool = false:
	set(value):
		test = value
		_test_view(value)
## _readyと同時にカウントダウン開始
@export var auto_start:bool = true
## カウントダウン中にGodotのPauseを使用
@export var use_paused:bool = true

@onready var countdown_label: Label = %CountdownLabel
@onready var overlay: Control = $Overlay
@onready var title_label: Label = $TitleLabel
@onready var moved_label: Label = $MovedLabel
@onready var exp_label_1: Label = %ExpLabel1
@onready var exp_label_2: Label = %ExpLabel2

var _tite_size:int = 64
var _outline:int = 20
var _main:Node

func _ready() -> void:
	_set_viwe()
	if !Engine.is_editor_hint():
		moved_label.visible = false
		overlay.visible = true
		title_label.visible = true
		if use_paused:
			await get_tree().process_frame
			_paused()
		if auto_start:
			if not SceneManager.is_fade_in:
				SceneManager.fade_in()
			start_countdown()
			

func _paused() -> void:
	get_tree().paused = true
	#main= get_tree().current_scene
	#if main == self:
		#print("mainはこのノードです。")
	#else:
		#main.set_process(false)
		#main.set_physics_process(false)
func _set_viwe() -> void:
	
	title_label.text = title_name + "!!!!"
	title_label.add_theme_color_override("font_color",title_color)
	title_label.add_theme_color_override("font_outline_color",Color(0,0,0)if outline_color_black else Color(1,1,1))
	if Engine.is_editor_hint():
		moved_label.text = title_name + "!!!!"
		moved_label.add_theme_color_override("font_color",title_color)
		moved_label.add_theme_color_override("font_outline_color",Color(0,0,0)if outline_color_black else Color(1,1,1))
		moved_label.visible = title_slide
		moved_label.position = after_position
		moved_label.add_theme_font_size_override("font_size",after_size)
		moved_label.add_theme_constant_override("outline_size",after_outline)
		moved_label.size = Vector2(64*moved_label.text.length(),65)
func _set_viwe_editor() -> void:
	if Engine.is_editor_hint() and is_node_ready():
		call_deferred("_set_viwe")

func _test_view(value:bool) -> void:
	if Engine.is_editor_hint():
		overlay.visible = !value
		title_label.visible = !value
		moved_label.modulate.a = 1 if value else 0.5
func start_countdown()-> void:
	visible = true
	GameManager.long_start = GameManager.settings.long_start
	if GameManager.long_start:
		_start_countdown_long()
		return
	AudioManager.play_BGM("res://titlemenu/assets/audio/kosenwaribiki_game1.ogg",0,0,1,true)
	await _show_countdown("3",Color(0,1,0))
	await _show_countdown("2",Color(1,0.5,0))
	await _show_countdown("1",Color(1,0,0))
	await _show_countdown("スタート！",Color(1,0,0))
	
	overlay.visible = false
	if title_slide:
		var tween = create_tween().set_parallel()
		tween.tween_property(title_label,"position",after_position,0.1).set_ease(Tween.EASE_OUT)
		tween.tween_property(self,"_tite_size",after_size,0.1).set_ease(Tween.EASE_OUT)
		tween.tween_property(self,"_outline",after_outline,0.1).set_ease(Tween.EASE_OUT)
		await tween.finished
	else:
		title_label.visible = false
	get_tree().paused = false
	game_start.emit()
func _process(delta: float) -> void:
	title_label.add_theme_font_size_override("font_size",_tite_size)
	title_label.add_theme_constant_override("outline_size",_outline)

func _show_countdown(text: String,color: Color,delay:float = 0.5,speed:float = 0.5) -> void:
	countdown_label.text = text
	countdown_label.add_theme_color_override("font_color",color)
	countdown_label.scale = Vector2(0.5, 0.5)
	
	var tween:Tween = create_tween()
	tween.tween_property(countdown_label, "scale", Vector2(1, 1), speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	await get_tree().create_timer(delay).timeout

func _start_countdown_long() -> void:
	AudioManager.play_BGM("res://titlemenu/assets/audio/kosenwaribiki_game1.ogg",0,0,1,true)
	title_label.position.x = 1155
	exp_label_1.position.x = 1152
	exp_label_2.position.x = 1152
	exp_label_1.visible = true
	exp_label_2.visible = true
	countdown_label.scale = Vector2(0, 0)
	var tween:Tween = create_tween().set_parallel()
	tween.tween_property(exp_label_1,"position:x",576-exp_label_1.size.x/2,0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(exp_label_2,"position:x",576-exp_label_2.size.x/2,0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(2.4)
	tween.tween_property(exp_label_1,"position:x",0-exp_label_1.size.x,0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(2.4)
	tween.tween_property(title_label,"position:x",576-title_label.size.x/2,0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(5.2)
	tween.tween_property(exp_label_2,"position:x",0-exp_label_2.size.x,0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(5.2)
	await tween.finished
	await get_tree().create_timer(2.65).timeout
	await _show_countdown("3",Color(0,1,0),0.32,0.4)
	await _show_countdown("2",Color(1,0.5,0),0.32,0.4)
	await _show_countdown("1",Color(1,0,0),0.32,0.4)
	await _show_countdown("スタート！",Color(1,0,0),0.32,0.4)
	overlay.visible = false
	if title_slide:
		var tween2 = create_tween().set_parallel()
		tween2.tween_property(title_label,"position",after_position,0.1).set_ease(Tween.EASE_OUT)
		tween2.tween_property(self,"_tite_size",after_size,0.1).set_ease(Tween.EASE_OUT)
		tween2.tween_property(self,"_outline",after_outline,0.1).set_ease(Tween.EASE_OUT)
		await tween2.finished
	else:
		title_label.visible = false
	get_tree().paused = false
	game_start.emit()
