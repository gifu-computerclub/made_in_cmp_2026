class_name VisibilingCheckButton
extends CheckButton

@export var on_visible_controls:Array[Control]
@export var off_visible_controls:Array[Control]
func _ready() -> void:
	for i in on_visible_controls:
		i.visible = button_pressed
	for i in off_visible_controls:
		i.visible = !button_pressed
	toggled.connect(_on_button_toggled)


func _on_button_toggled(toggled_on:bool) -> void:
	for i in on_visible_controls:
		i.visible = toggled_on
	for i in off_visible_controls:
		i.visible = !toggled_on
