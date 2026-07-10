class_name Helth
extends TextureRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func lost_helth() -> void:
	animation_player.play("lost_helth")
