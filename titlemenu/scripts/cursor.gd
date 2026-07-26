extends TextureRect
@export var shadow_color:Color

func shadow() -> void:
	modulate = shadow_color
	var tween:Tween = create_tween()
	tween.tween_property(self,"modulate:a",0.0,2.0)
	await tween.finished
	queue_free()
