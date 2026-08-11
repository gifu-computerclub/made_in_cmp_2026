extends Node2D


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_timer_ui_timeout() -> void:
	GameManager.game_over()
