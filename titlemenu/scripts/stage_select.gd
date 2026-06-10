extends Control

@onready var games_grid: GridContainer = %GamesGrid
var game_datas:Array[Discription]
var game_texs:Array[TextureRect]
func _ready() -> void:
	_set_game()
	await SceneManager.transition_finished
	AudioManager.play_BGM("res://titlemenu/assets/audio/gameselect.ogg",0,0,1,true)



func _set_game() -> void:
	game_datas = load_discription()
	for i in game_datas:
		var game_tex:TextureRect = preload("res://titlemenu/scenes/game_texture.tscn").instantiate()
		games_grid.add_child(game_tex)
		game_tex.set_dis(i)
		game_texs.append(game_tex)
	


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
