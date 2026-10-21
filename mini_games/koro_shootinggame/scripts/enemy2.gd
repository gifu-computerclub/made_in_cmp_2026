extends Marker2D
var moveminX: int = 20
var movemaxX: int
var speed: int = 200
var Bullet: PackedScene = preload("res://mini_games/koro_shootinggame/scenes/bullet.tscn")
@onready var shoot_timer: Timer = $ShootTimer
# Called when the node enters the scene tree for the first time.
func _ready():
	shoot_timer.timeout.connect(_on_timer_timeout)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_timer_timeout() -> void:
	for i in range(6):
		var bullet = Bullet.instantiate() as Area2D
		var theta: float = -45*i*PI/180
		bullet.global_position = global_position
		bullet.direction.x = cos(theta)
		bullet.direction.y = sin(theta)
		get_parent().add_child(bullet)
	pass
	
