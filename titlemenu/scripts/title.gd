extends Control

@onready var shutter: TextureRect = %Shutter
@onready var title_label: RichTextLabel = %TitleLabel

func _ready() -> void:
	AudioManager.play_BGM()
	pass


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("A"):
		title_label.visible = false
		var tween:Tween = create_tween()
		tween.tween_property(shutter,"scale",Vector2(1,0.1),1).set_ease(Tween.EASE_OUT)
		await tween.finished
		SceneManager.change_scene("res://titlemenu/scenes/stage_select.tscn",{"color":Color(1.0, 1.0, 1.0, 1.0)})
