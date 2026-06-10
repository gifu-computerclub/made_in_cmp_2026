class_name Discription
extends Resource

## ゲーム名を入力!!
@export var game_name:String
## これが君のゲームのシーンだ!!
@export var game_scene:PackedScene
## サムネを追加!!
@export var thambnail:Texture
## 操作方法をここに!!
@export_multiline() var oparation_instruction:String
## ゲームの説明をここに!!
@export_multiline() var game_instruction:String
