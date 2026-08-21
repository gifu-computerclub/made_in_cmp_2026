extends Button

@export var description:Description
@onready var thambnail: TextureRect = $HBoxContainer/Thambnail
@onready var title: Label = $HBoxContainer/Title
@onready var authe: Label = $HBoxContainer/Authe

func set_des() -> void:
	if description:
		thambnail.texture = description.thambnail
		title.text = description.game_name + "!!!!"
		authe.text = "作者:%d年生 <%s>" % [description.grade + 1,description.game_auther]




func _on_pressed() -> void:
	if description:
		AudioManager.play_BGM()
		GameManager.select_dis = description
		SceneManager.change_scene("res://titlemenu/scenes/description.tscn",{"color":Color("#000000"),"speed":2.0})
