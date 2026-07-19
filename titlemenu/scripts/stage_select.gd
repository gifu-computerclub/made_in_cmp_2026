extends Control

@onready var games_grid: GridContainer = %GamesGrid
@onready var cursor: TextureRect = %Cursor
@onready var title_label: Label = %TitleLabel
@onready var back_ground: TextureRect = %BackGround

var game_datas:Array[Description]
var game_texs:Array[TextureRect]
var cursor_offset:Vector2 = Vector2(-35,100)
func _ready() -> void:
	_set_game()
	await SceneManager.transition_finished
	AudioManager.play_BGM("res://titlemenu/assets/audio/gameselect.ogg",0,0,1,true)
	_select_start()


func _select_start() -> void:
	var rotate_minimum:int = 6 * game_texs.size()
	var game_number:int = 0
	var game_rondom: int = randi_range(0,game_texs.size())
	
	while game_rondom != 0 or rotate_minimum != 0:
		if game_number == game_texs.size() -1:
			game_number = 0
		else:
			game_number += 1
		if rotate_minimum > 0:
			rotate_minimum -= 1
		game_rondom = randi_range(0,game_texs.size())
		cursor.global_position = game_texs[game_number].global_position + (game_texs[game_number].get_rect().size / 2) + cursor_offset
		title_label.text = game_texs[game_number].get_game_name()
		await get_tree().create_timer(0.1).timeout 
	
	await get_tree().create_timer(0.5).timeout
	create_tween().tween_property(games_grid,"modulate:a",0,0.5)
	create_tween().tween_property(cursor,"modulate:a",0,0.5)
	create_tween().tween_property(title_label,"position:y",249,0.5)
	await get_tree().create_timer(0.5).timeout
	back_ground.texture = game_texs[game_number].texture
	back_ground.modulate = "#ffffff"
	create_tween().tween_property(title_label,"scale",Vector2(1.5,1.5),1.5)
	await get_tree().create_timer(1.0).timeout
	AudioManager.play_BGM()
	game_texs[game_number].change_scene()


func _set_game() -> void:
	game_datas = load_description()
	for i in game_datas:
		var game_tex:TextureRect = preload("res://titlemenu/scenes/game_texture.tscn").instantiate()
		games_grid.add_child(game_tex)
		game_tex.set_dis(i)
		game_texs.append(game_tex)
	


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
