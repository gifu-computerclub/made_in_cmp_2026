class_name Rhythm
extends Node2D

@onready var rhythm_show: MeshInstance2D = $RhythmShow
@onready var onpu: Sprite2D = $Onpu

var setting:int = 0
var moving:int = 0

func _ready() -> void:
	rhythm_show.hide()
	onpu.hide()
	rhythm_show.modulate = Color("#ff0")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if moving > 0:
		onpu.position.y -= moving ** 2
		moving -= 1

func rhythm_true():
	rhythm_show.show()
	onpu.show()
	setting = 1

signal miss
func key_pressed():
	if setting == 1:
		rhythm_show.hide()
		setting = 2
		moving = 7
	else:
		rhythm_show.show()
		rhythm_show.modulate = Color("#f00")
		miss.emit()
		setting = 3

func rhythm_reset():
	rhythm_show.hide()
	onpu.position.y = 140
	onpu.hide()
	if setting == 1:
		miss.emit()
	rhythm_show.modulate = Color("#ff0")
	setting = 0
