extends PanelContainer
class_name ToolTip
@onready var rich_text_label: RichTextLabel = %RichTextLabel

func _ready() -> void:
	scale = Vector2(0,0)

func set_tooltip(text:String,pos:Vector2) -> void:
	rich_text_label.text = text
	position = pos


func open() -> void:
	var tween:Tween = create_tween()
	tween.tween_property(self,"scale",Vector2(1,1),0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)

func close() -> void:
	var tween:Tween = create_tween()
	tween.tween_property(self,"scale",Vector2(0,0),0.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
