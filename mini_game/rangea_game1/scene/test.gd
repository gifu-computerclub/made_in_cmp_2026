extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
var toggle:bool = true

func _ready() -> void:
	$Timer.start()
	pass
func _process(delta: float) -> void:
	var diredtion:Vector2 = Vector2(1,0) if toggle else Vector2(-1,0)
	sprite_2d.position += diredtion * 50
	if sprite_2d.position.x > 980 or sprite_2d.position.x < 280:
		toggle = !toggle



func _on_timer_timeout() -> void:
	pass


func _on_timer_ui_timeout() -> void:
	#GameManager.game_clear()
	GameManager.game_over()
	pass
