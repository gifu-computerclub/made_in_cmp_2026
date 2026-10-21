extends Area2D

var direction: Vector2
var theta:float = 0
var wave: Vector2
var perpendicular_direction: Vector2

const SPEED:int = 150
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	perpendicular_direction.x = -direction.y
	perpendicular_direction.y = direction.x
	wave = perpendicular_direction * cos(theta)
	position += (direction * SPEED + 100 * wave) * delta
	theta += 2 * PI * delta
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		GameManager.game_over()
	pass # Replace with function body.
