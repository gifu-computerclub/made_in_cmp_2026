extends CharacterBody2D


const SPEED = 300
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	position.x = screen_size.x/2
	position.y = 450
	add_to_group("player")
	
func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_vector("left_left", "left_right", "left_up", "left_down")
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	
	position.x = clamp(position.x, 20, screen_size.x-20)
	position.y = clamp(position.y, 20, screen_size.y-20)
