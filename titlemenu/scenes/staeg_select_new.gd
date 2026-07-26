extends Control

@export var game_count:int = 3
@export var max_helth:int = 3
@export var helth_scene:PackedScene
@onready var helths_box: HBoxContainer = %HelthsBox
@onready var game_box: GridContainer = %GameBox
@onready var title_label: Label = %TitleLabel
@onready var cursor: TextureRect = %Cursor
@onready var back_ground: TextureRect = %BackGround

var helths:Array[Helth]
var rest_helth:int
var games:Array[Description]
var selected_games:Array[Description]
var shadow:bool = true
var cursor_offset:Vector2 = Vector2(-10,50)
func _ready() -> void:
	games = load_description()
	if games.size() < game_count:
		game_count = games.size()
		if game_count == 0:
			SceneManager.change_scene("res://titlemenu/scenes/title.tscn")
	if GameManager.rapid_game:
		_init_helth(GameManager.helth)
		AudioManager.play_BGM("res://titlemenu/assets/audio/gameselect.ogg",0.5,0,1,true)
		_init_game(GameManager.selected_game)
		await SceneManager.transition_finished
		if GameManager.rapid_game_over:
			GameManager.rapid_game_over = false
			await lost_helth()
		GameManager.selected_value += 1
		if GameManager.selected_value >= game_count:
			GameManager.rapid_game = 0
			SceneManager.change_scene("res://titlemenu/scenes/title.tscn")
		else:
			star_game(GameManager.selected_value)
	else:
		GameManager.selected_value = 0
		_init_helth()
		SceneManager.fade_in()
		await SceneManager.transition_finished
		AudioManager.play_BGM("res://titlemenu/assets/audio/gameselect.ogg",0,0,1,true)
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
	GameManager.helth = rest_count

func lost_helth() -> void:
	if rest_helth ==0:
		return
	rest_helth -= 1
	var tween:Tween = create_tween()
	var pos:Vector2 = helths_box.position
	tween.parallel().tween_property(helths_box,"position",Vector2(1152,648)/2 - helths_box.size*4/2,0.3).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(helths_box,"scale",Vector2(4,4),0.3).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	await get_tree().create_timer(0.4).timeout
	await helths[max_helth-rest_helth-1].lost_helth()
	await get_tree().create_timer(0.4).timeout
	var tween2:Tween = create_tween()
	tween2.parallel().tween_property(helths_box,"position",pos,0.3).set_ease(Tween.EASE_IN_OUT)
	tween2.parallel().tween_property(helths_box,"scale",Vector2(1,1),0.3).set_ease(Tween.EASE_IN_OUT)
	await tween2.finished
	GameManager.helth = rest_helth

func load_description() -> Array[Description]:
	var result:Array[Description] = []

	var dir := DirAccess.open("res://description")
	if dir == null:
		return result

	dir.list_dir_begin()

	var file_name := dir.get_next()
	while file_name != "":
		if !dir.current_is_dir() and file_name.ends_with(".tres"):
			var res := load("res://description/" + file_name)

			if res is Description:
				result.append(res)

		file_name = dir.get_next()

	dir.list_dir_end()

	return result

func _init_game_select() -> void:
	var game_tex:Array
	for i in range(game_count):
		var new_game:NinePatchRect = preload("res://titlemenu/scenes/new_game_texture.tscn").instantiate()
		game_box.add_child(new_game)
		await get_tree().create_timer(0.1).timeout
	for i in game_box.get_children():
		game_tex.append(i)
	for i in range(100):
		for j in game_tex:
			j.set_dis(games[randi_range(0,games.size()-1)])
		await get_tree().create_timer(0.015).timeout
	while game_tex:
		var selected_game:Description = games.pop_at(randi_range(0,games.size()-1))
		game_tex.pop_front().set_dis(selected_game)
		selected_games.append(selected_game)
		for i in range(20):
			for j in game_tex:
				j.set_dis(games[randi_range(0,games.size()-1)])
			await get_tree().create_timer(0.015).timeout
	GameManager.selected_game = selected_games
	GameManager.rapid_game = true

func _init_game(datas:Array[Description]) -> void:
	for i in range(game_count):
		var new_game:NinePatchRect = preload("res://titlemenu/scenes/new_game_texture.tscn").instantiate()
		game_box.add_child(new_game)
		new_game.set_dis(datas[i])
func star_game(num:int) -> void:
	var game_texs:Array
	for i in game_box.get_children():
		game_texs.append(i)
	title_label.text = game_texs[num].get_game_name()
	shadow = true
	_start_shadow()
	var tween:Tween = create_tween()
	var cursor_position = game_texs[num].global_position + (game_texs[num].get_rect().size / Vector2(2,1)) + cursor_offset
	tween.tween_property(cursor,"global_position",cursor_position,1)
	await tween.finished
	shadow = false
	for i in range(3):
		var tween2:Tween = create_tween()
		tween2.tween_property(game_texs[num],"modulate:a",0.3,0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween2.tween_property(game_texs[num],"modulate:a",1.0,0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await tween2.finished
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
	GameManager.rapid_game = true
	game_texs[num].change_scene()

func _start_shadow() -> void:
	while shadow:
		var shadow_cursor :TextureRect= preload("res://titlemenu/scenes/cursor.tscn").instantiate()
		$Control.add_child(shadow_cursor)
		shadow_cursor.global_position = cursor.global_position
		shadow_cursor.shadow()
		await get_tree().create_timer(0.05).timeout
