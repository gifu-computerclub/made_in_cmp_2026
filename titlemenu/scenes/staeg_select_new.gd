extends Control

@export var game_count:int = 3
@export var max_helth:int = 3
@export var helth_scene:PackedScene
@onready var helths_box: HBoxContainer = %HelthsBox
@onready var game_box: HBoxContainer = %GameBox
@onready var title_label: Label = %TitleLabel
@onready var cursor: TextureRect = %Cursor
@onready var back_ground: TextureRect = %BackGround

var helths:Array[Helth]
var rest_helth:int
var games:Array[Discription]
var selected_games:Array[Discription]
func _ready() -> void:
	games = load_discription()
	_init_helth(2)
	SceneManager.fade_in()
	await SceneManager.transition_finished
	AudioManager.play_BGM("res://titlemenu/assets/audio/gameselect.ogg",0,0,1,true)
	lost_helth()
	await _init_game_select()
	star_game(0)
func _init_helth(rest_count:int = max_helth) -> void:
	for i in range(max_helth):
		var helth:Helth = helth_scene.instantiate()
		helths_box.add_child(helth)
		helths.append(helth)
	for i in range(max_helth-rest_count):
		helths[i].lost_helth()
	rest_helth = rest_count

func lost_helth() -> void:
	if rest_helth ==0:
		return
	rest_helth -= 1
	helths[max_helth-rest_helth-1].lost_helth()

func load_discription() -> Array[Discription]:
	var result:Array[Discription] = []

	var dir := DirAccess.open("res://discription")
	if dir == null:
		return result

	dir.list_dir_begin()

	var file_name := dir.get_next()
	while file_name != "":
		if !dir.current_is_dir() and file_name.ends_with(".tres"):
			var res := load("res://discription/" + file_name)

			if res is Discription:
				result.append(res)

		file_name = dir.get_next()

	dir.list_dir_end()

	return result

func _init_game_select() -> void:
	var game_tex:Array
	for i in game_box.get_children():
		game_tex.append(i)
	for i in range(100):
		for j in game_tex:
			j.set_dis(games[randi_range(0,games.size()-1)])
		await get_tree().create_timer(0.015).timeout
	while game_tex:
		var selected_game:Discription = games.pop_at(randi_range(0,games.size()-1))
		game_tex.pop_front().set_dis(selected_game)
		selected_games.append(selected_game)
		for i in range(20):
			for j in game_tex:
				j.set_dis(games[randi_range(0,games.size()-1)])
			await get_tree().create_timer(0.015).timeout
	

func star_game(num:int) -> void:
	var game_texs:Array
	for i in game_box.get_children():
		game_texs.append(i)
	title_label.text = game_texs[num].get_game_name()
	for i in range(3):
		var tween:Tween = create_tween()
		tween.tween_property(game_texs[num],"modulate:a",0.3,0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(game_texs[num],"modulate:a",1.0,0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await tween.finished
	title_label.visible = true
	title_label.modulate.a = 0
	create_tween().tween_property(game_box,"modulate:a",0,0.5)
	create_tween().tween_property(cursor,"modulate:a",0,0.5)
	create_tween().set_parallel().tween_property(title_label,"position:y",249,0.5)
	create_tween().set_parallel().tween_property(title_label,"modulate:a",1,0.5)
	await get_tree().create_timer(0.5).timeout
	back_ground.texture = game_texs[num].get_game_texture()
	back_ground.modulate = "#ffffff"
	create_tween().tween_property(title_label,"scale",Vector2(1.5,1.5),1.5)
	await get_tree().create_timer(1.0).timeout
	AudioManager.play_BGM()
	game_texs[num].change_scene()
