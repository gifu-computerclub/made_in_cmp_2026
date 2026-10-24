extends ArielGame1Character

func player()->void:
	pass

func _ready() -> void:
	super._ready()
	change_health.connect(_on_health_changed)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed(&"l"):
		move(&"left")
	elif Input.is_action_pressed(&"r"):
		move(&"right")
	else:
		move(&"middle")
	#print(sneeking)
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"a"):
		punch()
	if event.is_action_pressed(&"b"):
		sneek()

func _on_health_changed()->void:
	main.player_hp.value = health
	if health <= 0:
		GameManager.game_over()
