extends Node2D

const UNIT_MEASURE:int = 96
const CHART:Array[Array] = [[1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0],
							[1,0,0,0,1,0,0,0,1,0,1,0,1,0,0,0],
							[1,0,1,0,1,0,0,0,1,1,1,0,1,0,0,0],
							[1,0,0,0,1,0,0,0,1,1,1,1,1,0,0,0],
							[1,0,1,0,1,1,1,0,1,1,1,0,1,0,0,0],
							[1,0,1,1,0,1,1,0,1,0,1,0,1,0,0,0],
							[1,0,1,1,1,0,1,0,1,1,1,0,1,0,0,0],
							[1,0,1,0,1,1,0,0,1,1,0,0,1,1,1,0],
							[1,0,1,1,1,1,1,0,1,1,1,1,1,1,1,0],
							[1,0,1,1,1,0,1,1,0,1,1,1,0,1,1,0],
							[0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0],
							[1,1,1,1,0,1,1,1,1,1,0,1,1,0,1,0]]

@onready var music_bar: MeshInstance2D = $MusicBar
@onready var turn_show: RichTextLabel = $TurnShow
@onready var heart_container: HBoxContainer = $HeartContainer

var rhythm_frames:Array[Rhythm] = []
var start_frame:int
var stop_process:bool = true
var chart_load:int = 0
var turn:int = 0
var beat:int = 0
var music_frame:int = 0
var miss_turn:Array[int] = []
var offset:int = 1
var heart = 3
var hearts:Array[Heart] = []

func _ready() -> void:
	music_bar.position.x = -9 + offset*10
	turn_show.text = "[font size=40]turn [color=ff0000]1/12"
	for i in range(heart):
		var heart_unit:TextureRect = preload("res://mini_games/takasou_game1/scenes/heart.tscn").instantiate()
		heart_container.add_child(heart_unit)
		hearts.append(heart_unit)
	for i in range(16):
		var rhythm_frame:Node2D = preload("res://mini_games/takasou_game1/scenes/rhythm_square.tscn").instantiate()
		add_child(rhythm_frame)
		rhythm_frames.append(rhythm_frame)
		rhythm_frame.position = Vector2(126+60*i,200)
		rhythm_frame.rhythm_show.hide()
		rhythm_frame.miss.connect(turn_miss)

func _physics_process(delta: float) -> void:
	music_frame += 1
	if music_frame == UNIT_MEASURE*(4+2*turn):
		if music_frame >= 2496:	
			GameManager.game_clear("完走！")
			set_physics_process(false)
			return
		for i in range(16):
			rhythm_frames[i].rhythm_reset()
		turn += 1
		beat = 0
		turn_show.text = "[font size=40]turn [color=ff0000]" + str(turn+1) + "/12"
	if music_frame == UNIT_MEASURE*(2+2*turn)+6*beat and music_frame < UNIT_MEASURE*(2+2*turn)+96:
		if CHART[turn][beat] == 1:
			rhythm_frames[beat].rhythm_true()
		beat += 1
	if music_frame == UNIT_MEASURE*(3+2*turn)-14:
		stop_process = false
	elif music_frame == UNIT_MEASURE*(4+2*(turn-1))+14:
		stop_process = true
		music_bar.position.x = -9 + offset*10
	if stop_process == false:
		music_bar.position.x += 10

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		if music_bar.position.x >= 126 and music_bar.position.x <= 1026:
			rhythm_frames[int(music_bar.position.x - 126) / 60].key_pressed()

func _on_start_overlay_music_started() -> void:
	music_frame = UNIT_MEASURE*2-1

func turn_miss():
	if not(miss_turn.has(turn)):
		hearts[miss_turn.size()].brake()
		miss_turn.append(turn)
		if miss_turn.size() >= heart:
			await get_tree().create_timer(0.1).timeout
			GameManager.game_over()
