extends Control

@export var title_name:String = "タイトル"
@export var title_color:Color = Color(0,0,1)
@export var outline_color_black:bool = false
@export_group("Title Slide")
@export_custom(PROPERTY_HINT_GROUP_ENABLE,"") var title_slide:bool = true
@export var after_position:Vector2 = Vector2(537,103)
@export var after_size:int = 64
@export var after_outline:int = 20
@export var test:bool = false
@onready var countdown_label: Label = %CountdownLabel
@onready var overlay: Control = $Overlay
@onready var title_label: Label = $TitleLabel


func _ready() -> void:
	_set_viwe()
	start_countdown()

func _set_viwe() -> void:
	title_label.text = title_name + "!!!!"
	title_label.add_theme_color_override("font_color",title_color)

func start_countdown()-> void:
	visible = true
	AudioManager.play_BGM("res://titlemenu/assets/audio/kosenwaribiki_game1.ogg",0,0,1,true)
	await show_countdown("3",Color(0,1,0))
	await show_countdown("2",Color(1,0.5,0))
	await show_countdown("1",Color(1,0,0))
	await show_countdown("スタート！",Color(1,0,0))
	
	overlay.visible = false
	if title_slide:
		var tween = create_tween()
		tween.tween_property(title_label,"position",after_position,0.1).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(self,"tite_size",after_size,0.1)
		tween.parallel().tween_property(self,"outline",after_outline,0.1)
		await tween.finished
	else:
		title_label.visible = false

func show_countdown(text: String,color: Color) -> void:
	countdown_label.text = text
	countdown_label.add_theme_color_override("font_color",color)
	countdown_label.scale = Vector2(0.5, 0.5)
	
	var tween:Tween = create_tween()
	tween.tween_property(countdown_label, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	await get_tree().create_timer(0.5).timeout
