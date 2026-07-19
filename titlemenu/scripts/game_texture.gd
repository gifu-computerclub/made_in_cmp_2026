extends TextureRect

var description:Description


func get_game_name() -> String:
	if description:
		return description.game_name
	return ""
func set_dis(d:Description) -> void:
	description = d
	texture = description.thambnail

func change_scene() -> void:
	GameManager.select_dis = description
	SceneManager.change_scene("res://titlemenu/scenes/description.tscn",{"color":Color("#000000"),"speed":2.0})
