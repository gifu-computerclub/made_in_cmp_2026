extends Marker2D
var theta: float = 0
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
	for i in range(4):
		var bullet = Bullet.instantiate() as Area2D
		bullet.global_position = global_position
		bullet.direction.x = cos(theta)
		bullet.direction.y = sin(theta)
		theta = 60*i*PI/180
		get_parent().add_child(bullet)
	pass
	
