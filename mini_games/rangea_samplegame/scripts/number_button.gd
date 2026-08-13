extends Button

var number:int = 0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	text = "%dこ" % number

func correct() -> void:
	release_focus()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	animation_player.play("correct")

func incorrect() -> void:
	release_focus()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	animation_player.play("incorrect")
