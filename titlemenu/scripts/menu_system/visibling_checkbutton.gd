class_name VisibilingCheckButton
extends CheckButton

## オンの時に表示されます。
@export var on_visible_controls:Array[NodePath]

## オフの時に表示されます。こちらが優先されます。
@export var off_visible_controls:Array[NodePath]
func _ready() -> void:
	_on_button_toggled(button_pressed)
	toggled.connect(_on_button_toggled)


func _on_button_toggled(toggled_on:bool) -> void:
	var root := get_parent().get_parent() # TabContainerなど
	for path in on_visible_controls:
		var node := get_node_or_null(path)
		if node is Control:
			node.visible = toggled_on

	for path in off_visible_controls:
		var node := get_node_or_null(path)
		if node is Control:
			node.visible = !toggled_on
