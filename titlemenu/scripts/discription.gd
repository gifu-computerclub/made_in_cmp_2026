extends Control

@export var description:Description

@onready var start: Button = %Start
@onready var cursor: TextureRect = %Cursor
@onready var time_label: Label = %TimeLabel
@onready var thumbnail: TextureRect = %Thumbnail
@onready var oparation_instruction: Label = %OparationInstruction
@onready var game_instruction: Label = %GameInstruction
@onready var game_name: Label = %GameName
@onready var timer: Timer = $Timer
@onready var author: Label = %Author

var timer_time:float = 11.0
func _ready() -> void:
	timer.wait_time = timer_time
	timer.start()
	if GameManager.select_dis:
		description = GameManager.select_dis
	cursor.global_position = start.global_position + Vector2(-40,0)
	start.grab_focus()
	set_dis()
	AudioManager.play_BGM("res://titlemenu/assets/audio/Logic&Contradiction.ogg",0,0,1,true)
func _process(delta: float) -> void:
	time_label.text = str(int(round(timer.time_left)))

func set_dis() -> void:
	if not Description:
		return
	game_name.text = description.game_name + "!!!!"
	author.text = "作者:%s" % (description.game_auther if description.game_auther != "" else "匿名")
	if description.thumbnail:
		thumbnail.texture = description.thumbnail
	oparation_instruction.text = description.oparation_instruction
	game_instruction.text = description.game_instruction



func _on_start_pressed() -> void:
	if description == null or description.game_scene == null:
		SceneManager.change_scene("res://titlemenu/scenes/title.tscn")
	else:
		SceneManager.change_scene(description.game_scene)
