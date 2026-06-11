extends TextureRect

var discription:Discription


func get_game_name() -> String:
	if discription:
		return discription.game_name
	return ""
func set_dis(d:Discription) -> void:
	discription = d
	texture = discription.thambnail

func change_scene() -> void:
	GameManager.select_dis = discription
	SceneManager.change_scene("res://titlemenu/scenes/discription.tscn",{"color":Color("#000000"),"speed":2.0})
