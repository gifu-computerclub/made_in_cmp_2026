extends NinePatchRect

@onready var game_texture: TextureRect = %GameTexture
@onready var title: Label = $VBoxContainer/Title

var description:Description


func get_game_name() -> String:
	return game_texture.get_game_name()
func get_game_texture() -> Texture:
	return game_texture.texture
func set_dis(d:Description) -> void:
	game_texture.set_dis(d)
	title.text = game_texture.get_game_name()

func change_scene() -> void:
	game_texture.change_scene()
