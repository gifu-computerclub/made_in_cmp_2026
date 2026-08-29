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
	file_dialog.clear_filters()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	file_dialog.add_filter("*.tres", "Description")
	file_dialog.current_dir = "res://description"
	file_dialog.current_file = ""
	_set_callback(_save_resource_description)
	file_dialog.popup_centered_ratio(0.6)

func _save_resource_description(path: String) -> void:
	if not path.begins_with("res://description/"):
		push_error("descriptionフォルダのみ保存できます")
		return

	if not path.ends_with(".tres"):
		path += ".tres"

	if ResourceLoader.exists(path):
		_show_error("上書き保存は許可されていません。")
		return

	var data := Description.new()

	var error := ResourceSaver.save(data, path)
	if error != OK:
		push_error("Descriptionの保存に失敗しました: %s" % error)
		return

	EditorInterface.get_resource_filesystem().scan()

	var reloaded := load(path)
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

	if not folder_path.begins_with("res://mini_games/"):
		push_error("mini_gamesフォルダ内のみ作成できます")
		return

	if DirAccess.dir_exists_absolute(folder_path):
		_show_error("同じ名前のミニゲームフォルダが既に存在します。")
		return

	# ========================================
	# フォルダ作成
	# ========================================

	for folder in ["", "assets", "scenes", "scripts"]:
		var target := folder_path.path_join(folder)

		var error := DirAccess.make_dir_recursive_absolute(target)

		if error != OK:
			push_error("フォルダの作成に失敗しました: %s" % target)
			return

	var scene_path := folder_path.path_join("scenes/main.tscn")
	var script_path := folder_path.path_join("scripts/main.gd")

	# ========================================
	# main.gdをコピー
	# ========================================

	var error := DirAccess.copy_absolute(
		"res://addons/madeincmp/templates/main.gd",
		script_path
	)

	if error != OK:
		push_error("main.gdのコピーに失敗しました: %s" % error)
		return

	# ========================================
	# テンプレートSceneを読み込む
	# ========================================

	const TEMPLATE_SCENE := \
		"res://addons/madeincmp/templates/main.tscn"

	var file := FileAccess.open(
		TEMPLATE_SCENE,
		FileAccess.READ
	)

	if file == null:
		push_error("テンプレートSceneを開けませんでした")
		return

	var scene_text := file.get_as_text()
	file.close()

	# ========================================
	# Scene自身のUIDを削除
	# ========================================

	var lines := scene_text.split("\n")

	for i in lines.size():
		if lines[i].begins_with("[gd_scene "):
			var regex := RegEx.new()

			regex.compile(' uid="uid://[^"]+"')

			lines[i] = regex.sub(lines[i], "", true)

			break

	scene_text = "\n".join(lines)

	# ========================================
	# main.gdの参照先を変更
	# ========================================

	var script_regex := RegEx.new()

	script_regex.compile(
		'\\[ext_resource type="Script" uid="uid://[^"]+" path="res://addons/madeincmp/templates/main\\.gd"'
	)

	scene_text = script_regex.sub(
		scene_text,
		'[ext_resource type="Script" path="%s"' % script_path,
		true
	)

	# ========================================
	# 新しいSceneを保存
	# ========================================

	file = FileAccess.open(
		scene_path,
		FileAccess.WRITE
	)

	if file == null:
		push_error("main.tscnを作成できませんでした")
		return

	file.store_string(scene_text)
	file.close()

	# ========================================
	# ファイルシステム更新
	# ========================================

	EditorInterface.get_resource_filesystem().scan()

	# ========================================
	# Sceneを開く
	# ========================================

	EditorInterface.open_scene_from_path(scene_path)

func _set_callback(callback: Callable) -> void:
	for c in file_dialog.file_selected.get_connections():
		file_dialog.file_selected.disconnect(c.callable)

	file_dialog.file_selected.connect(callback)

func _show_error(message: String) -> void:
	error_dialog.dialog_text = message
	error_dialog.popup_centered()
