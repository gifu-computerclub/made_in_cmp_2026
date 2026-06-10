extends Control

func _ready() -> void:
	await SceneManager.transition_finished
	AudioManager.play_BGM("res://titlemenu/assets/audio/gameselect.ogg",0,0,1,true)
