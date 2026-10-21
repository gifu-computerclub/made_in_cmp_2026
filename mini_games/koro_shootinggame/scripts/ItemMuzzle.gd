extends Marker2D

const Item = preload("res://mini_games/koro_shootinggame/scenes/item.tscn")
@onready var shoot_timer: Timer = $ShootTimer
signal ScoreAdd()
# Called when the node enters the scene tree for the first time.
func _ready():
	shoot_timer.timeout.connect(_on_timer_timeout)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_timer_timeout() -> void:
	var item = Item.instantiate() as Area2D
	item.GetItem.connect(_on_item)
	item.global_position.x = randi_range(20, get_viewport_rect().size.x-20)
	item.global_position.y = randi_range(250,500)
	get_parent().add_child(item)
	pass
	
func _on_item() -> void:
	emit_signal("ScoreAdd")
