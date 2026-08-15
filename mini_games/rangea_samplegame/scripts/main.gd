extends Node2D

@export var min_number:int = 15
@export var max_number:int = 30
@export_range(3,10,1) var button_number:int = 3
@export var accept:int = 5

var true_number:int
var numbers:Array[int]
var buttons:Array[Button]
@onready var start_overlay: Control = %StartOverlay
@onready var count_targets: Node2D = %CountTargets
@onready var button_container: GridContainer = %ButtonContainer
@onready var timer_ui: TimerUi = %TimerUi


func _ready() -> void:
	true_number = randi_range(min_number,max_number)
	print("正解:",true_number)
	ganerate_number()
	await start_overlay.game_start
	ganerate_target()
	ganarate_buttons()
	

func ganerate_target() -> void:
	for i in range(true_number):
		var target:Sprite2D = preload("res://mini_games/rangea_samplegame/scenes/count_target.tscn").instantiate()
		count_targets.add_child(target)

func ganerate_number() -> void:
	numbers.append(true_number)
	
	for i in range(button_number-1):
		var select_number:int = randi_range(true_number-accept,true_number+accept)
		while numbers.has(select_number):
			select_number = randi_range(true_number-accept,true_number+accept)
		numbers.append(select_number)
	numbers.sort()
	print(numbers)

func ganarate_buttons() -> void:
	for num:int in numbers:
		var button:Button = preload("res://mini_games/rangea_samplegame/scenes/number_button.tscn").instantiate()
		button.number = num
		button_container.add_child(button)
		buttons.append(button)
		button.pressed.connect(_on_buttons_pressed.bind(button))
	buttons[0].grab_focus()

func _on_buttons_pressed(button:Button) -> void:
	if button.number == true_number:
		game_clear()
	else:
		game_over()
func corrctness_check() -> void:
	timer_ui.stop()
	for bu in buttons:
		if bu.number == true_number:
			bu.correct()
		else:
			bu.incorrect()
	await get_tree().create_timer(0.5).timeout

func game_clear() -> void:
	var clear_time:int = timer_ui.wait_time - timer_ui.get_remiting_time()
	await corrctness_check()
	GameManager.game_clear("クリア時間:%d秒"%clear_time)
func game_over() -> void:
	await corrctness_check()
	GameManager.game_over()
