extends Control

@onready var debug_selects_container: VBoxContainer = %DebugSelectsContainer

var games:Array[Description]

func _ready() -> void:
	games = GameManager.load_description()
	_set_gama_select()
	await SceneManager.transition_finished
	AudioManager.play_BGM("res://titlemenu/assets/audio/gameselect.ogg",0,0,1,true)

func _set_gama_select() -> void:
	for des in games:
		var button:Button = preload("res://titlemenu/scenes/debug_button.tscn").instantiate()
		debug_selects_container.add_child(button)
		button.description = des
		button.set_des()
