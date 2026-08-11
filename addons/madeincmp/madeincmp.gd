@tool
extends EditorPlugin

var file_dialog: EditorFileDialog
var error_dialog: AcceptDialog


func _enter_tree():
	#region ダイアログ作成
	file_dialog = EditorFileDialog.new()
	get_editor_interface().get_base_control().add_child(file_dialog)
	error_dialog = AcceptDialog.new()
	error_dialog.title = "エラー"
	get_editor_interface().get_base_control().add_child(error_dialog)
	#endregion
	
	#region 
	add_tool_menu_item("MadeInCMP/ミニゲームを登録", _create_description)
	add_tool_menu_item("MadeInCMP/ミニゲームファイルを作成", _create_minigame)
	#endregion

func _exit_tree():
	remove_tool_menu_item("MadeInCMP/ミニゲームを登録")
	remove_tool_menu_item("MadeInCMP/ミニゲームファイルを作成")

func _create_description() -> void:
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	file_dialog.add_filter("*.tres", "Description")
	file_dialog.current_dir = "res://description"
	file_dialog.current_file = ""
	_set_callback(_save_resource_description)
	file_dialog.popup_centered_ratio(0.6)

func _save_resource_description(path:String):
	
	if !path.begins_with("res://description/"):
		push_error("descriptionフォルダのみ保存できます")
		return
	
	if ResourceLoader.exists(path):
		_show_error("上書き保存は許可されていません。")
		return

	var data := Description.new()
	ResourceSaver.save(data, path)
	# ファイルシステム更新
	EditorInterface.get_resource_filesystem().scan()

	# 開き直す
	var reloaded = load(path)

	EditorInterface.inspect_object(reloaded)

func _create_minigame() -> void:
	file_dialog.clear_filters()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	file_dialog.current_dir = "res://mini_games"
	file_dialog.current_file = ""

	_set_callback(_create_minigame_folder)

	file_dialog.popup_centered_ratio(0.6)

func _create_minigame_folder(path: String) -> void:
	var folder_path := path.get_basename()

	if !folder_path.begins_with("res://mini_games/"):
		push_error("mini_gamesフォルダ内のみ作成できます")
		return
	
	if DirAccess.dir_exists_absolute(folder_path):
		_show_error("同じ名前のミニゲームフォルダが既に存在します。")
		return

	DirAccess.make_dir_recursive_absolute(folder_path)
	DirAccess.make_dir_recursive_absolute(folder_path.path_join("assets"))
	DirAccess.make_dir_recursive_absolute(folder_path.path_join("scenes"))
	DirAccess.make_dir_recursive_absolute(folder_path.path_join("scripts"))

	var scene_path := folder_path.path_join("scenes/main.tscn")
	var script_path := folder_path.path_join("scripts/main.gd")

	# テンプレートをコピー
	DirAccess.copy_absolute(
		"res://addons/madeincmp/templates/main.tscn",
		scene_path
	)

	DirAccess.copy_absolute(
		"res://addons/madeincmp/templates/main.gd",
		script_path
	)

	EditorInterface.get_resource_filesystem().scan()

	# シーンを読み込む
	var packed_scene: PackedScene = load(scene_path)
	var root := packed_scene.instantiate()

	# コピーしたスクリプトを読み込む
	var script: Script = load(script_path)

	# ルートノードにアタッチ
	root.set_script(script)

	# シーンを保存し直す
	var new_scene := PackedScene.new()
	new_scene.pack(root)
	ResourceSaver.save(new_scene, scene_path)

	EditorInterface.get_resource_filesystem().scan()

	EditorInterface.open_scene_from_path(scene_path)

func _set_callback(callback: Callable) -> void:
	for c in file_dialog.file_selected.get_connections():
		file_dialog.file_selected.disconnect(c.callable)

	file_dialog.file_selected.connect(callback)

func _show_error(message: String) -> void:
	error_dialog.dialog_text = message
	error_dialog.popup_centered()
