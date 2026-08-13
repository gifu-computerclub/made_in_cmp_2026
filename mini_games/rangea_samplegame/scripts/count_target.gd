extends Sprite2D

@export var min_movement:Vector2
@export var max_movement:Vector2
@export var min_time:float = 1.0
@export var max_time:float = 2.0

var tween:Tween

func _ready() -> void:
	position = set_random_position()
	_randam_move()

func _process(delta: float) -> void:
	if tween == null or !tween.is_running():
		_randam_move()

func _randam_move() -> void:
	var moved_position:Vector2 = set_random_position()
	var time:float = randf_range(min_time,max_time)
	tween = create_tween()
	tween.tween_property(self,"position",moved_position,time)
	await tween.finished

func set_random_position() -> Vector2:
	var moved_position_x:float = randf_range(min_movement.x,max_movement.x)
	var moved_position_y:float = randf_range(min_movement.y,max_movement.y)
	return Vector2(moved_position_x,moved_position_y)
