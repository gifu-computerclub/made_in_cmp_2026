extends Node2D

var my_hand:int
var teki_hand:int
var mati:bool = true
var buttons:Array[Button]
var kill:int = 10

@export var textures:Array[Texture]
@onready var h_box_container: HBoxContainer = $CanvasLayer/Control/HBoxContainer
@onready var texture_rect: TextureRect = $CanvasLayer/Control/TextureRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var you_lose: Control = $CanvasLayer/YouLose
@onready var label: Label = $CanvasLayer/Control/Label



const BUTTON = preload("res://mini_games/SORIO_Game1/scenes/Button.tscn")

func _ready() -> void:
	you_lose.hide()
	label.hide()
	var te:int = 0
	teki_hand = randi_range(0,2)
	if(randi_range(1,kill)==1):
		teki_hand = 3
	for i in textures:
		var button:Button = BUTTON.instantiate()
		button.icon = i
		button.button_down.connect(_on_button_downed.bind(button))
		button.number = te
		buttons.append(button)
		h_box_container.add_child(button)
		button.grab_focus()
		te += 1
	hand_loop()

func _process(delta: float) -> void:
		pass

func _on_timer_ui_timeout() -> void:
	GameManager.game_over()

func _on_button_downed(button:Button):
	button.release_focus()
	mati = false
	my_hand = button.number
	if(teki_hand == 3):
		texture_rect.texture = preload("res://mini_games/SORIO_Game1/assets/finger_count09.png")
		lose()
		return
	texture_rect.texture = textures[teki_hand]
	if(my_hand == teki_hand-1 || (my_hand == 2 && teki_hand == 0)):
		win()
	elif(my_hand == teki_hand):
		draw(button)
	else:
		lose()
	

func hand_loop():
	var counter:int = 0
	while mati :
		texture_rect.texture = textures[counter % 3]
		counter += 1
		await get_tree().create_timer(0.05).timeout

func win():
	GameManager.game_clear()

func lose():
	you_lose.show()
	animation_player.play("you_lose")
	await animation_player.animation_finished
	GameManager.game_over()

func draw(button:Button):
	label.show()
	await get_tree().create_timer(1).timeout
	label.hide()
	kill -= 1
	mati = true
	teki_hand = randi_range(0,2)
	if(randi_range(1,kill)==1):
		teki_hand = 3
	hand_loop()
	button.grab_focus()

	
