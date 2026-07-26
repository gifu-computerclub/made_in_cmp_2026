@icon("res://titlemenu/assets/texture/icons/description.svg")
@tool
class_name Description
extends Resource

func _get_custom_preview_texture() -> Texture2D:
	return preload("res://titlemenu/assets/texture/icons/description.svg")
## ゲーム名を入力!!
@export var game_name:String
## これが君のゲームのシーンだ!!
@export var game_scene:PackedScene
## このゲームは誰が作ったんだい?
@export var game_auther:String
## 君の学年を教えてくれ
@export_enum("1年生","2年生","3年生","4年生","5年生") var grade:int = 0
## サムネを追加!!
@export var thambnail:Texture
## 操作方法をここに!!
@export_multiline() var oparation_instruction:String
## ゲームの説明をここに!!
@export_multiline() var game_instruction:String
