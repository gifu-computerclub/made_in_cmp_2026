@tool
extends EditorPlugin

const MainScane:String = "res://addons/audiomanager/audio_manager.tscn"
const DEFAULT_BUS_LAYOUT:String = "res://addons/audiomanager/default_bus_layout.tres"
func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	add_autoload_singleton("AudioManager",MainScane)
	apply_default_bus_if_needed()


func _exit_tree() -> void:
	remove_autoload_singleton("AudioManager")

func apply_default_bus_if_needed():
	var current = ProjectSettings.get("audio/default_bus_layout")

	# 未設定 or 空の場合のみ適用
	if current == null or current == "":
		print("デフォルトAudioBusを適用します")

		ProjectSettings.set("audio/default_bus_layout", DEFAULT_BUS_LAYOUT)
		ProjectSettings.save()

		# 即時反映（重要）
		var layout = load(DEFAULT_BUS_LAYOUT)
		if layout:
			AudioServer.set_bus_layout(layout)
