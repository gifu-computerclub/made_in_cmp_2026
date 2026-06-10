extends Control

@export var discription:Discription

@onready var start: Button = %Start
@onready var cursor: TextureRect = %Cursor
@onready var time_label: Label = %TimeLabel
@onready var thambnail: TextureRect = %Thambnail
@onready var oparation_instruction: Label = %OparationInstruction
@onready var game_instruction: Label = %GameInstruction
@onready var game_name: Label = %GameName

func _ready() -> void:
	cursor.global_position = start.global_position + Vector2(-40,0)
	start.grab_focus()
	set_dis()
	AudioManager.play_BGM("res://titlemenu/assets/audio/Logic&Contradiction.ogg",0,0,1,true)


func set_dis() -> void:
	if not discription:
		return
	game_name.text = discription.game_name
	thambnail.texture = discription.thambnail
	oparation_instruction.text = discription.oparation_instruction
	game_instruction.text = discription.game_instruction



func _on_start_pressed() -> void:
	if discription == null or discription.game_scene == null:
		SceneManager.change_scene("res://titlemenu/scenes/title.tscn")
	else:
		SceneManager.change_scene(discription.game_scene)
