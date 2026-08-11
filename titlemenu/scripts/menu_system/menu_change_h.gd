@tool
extends HBoxContainer
class_name MenuChangeHBox

@export var tab_menu:TabMenu:
	set(value):
		tab_menu = value
		notify_property_list_changed()
		if value == null:
			data_strings = {}
@export var data_strings:Dictionary[Button,String]
var buttons:Array[Button]


#region インスペクター
func _get_property_list() -> Array[Dictionary]:
	var datas:Array[Dictionary]
	if tab_menu:
		var names:String = ",".join(tab_menu.get_all_tab_titles())
		var buttons_names:Array[String] = _get_buttons_name()
		for  i in buttons_names:
			datas.append({
				"name":"datas/%s" % [i],
				"type":TYPE_STRING,
				"hint":PROPERTY_HINT_ENUM,
				"hint_string":names,
			})
	return datas
func _validate_property(property: Dictionary) -> void:
	if property.name == "data_strings":
		property.usage = PROPERTY_USAGE_NO_EDITOR

func _set(property, value):
	if property.begins_with("datas/"):
		var node_name :String= property.get_slice("/", 1)
		var ctrl := get_node_or_null(node_name) as Button
		if ctrl:
			data_strings[ctrl] = value
			return true
	return false
func _get(property):
	if property.begins_with("datas/"):
		var node_name :String= property.get_slice("/", 1)
		var ctrl := get_node_or_null(node_name) as Button
		if ctrl and data_strings.has(ctrl):
			return data_strings[ctrl]
		return ""
	return null
func _property_can_revert(property: StringName) -> bool:
	for child in _get_buttons_name():
		var pro_name:StringName = &"datas/%s"% child
		if property == pro_name:
			return true
	return false
func _property_get_revert(property: StringName) -> Variant:
	for child in _get_buttons_name():
		var pro_name:StringName = &"datas/%s"% child
		if property == pro_name:
			return ""
	return null
func _notification(what):
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		call_deferred("_update_data_strings")
func _update_data_strings() -> void:
	_sync_data_strings()
	notify_property_list_changed()
func _sync_data_strings() -> void:
	var valid_buttons: Array[Button] = []

	for button_name in _get_buttons_name():
		var button := get_node_or_null(button_name) as Button
		if button:
			valid_buttons.append(button)

	for button in data_strings.keys():
		if not is_instance_valid(button) or button not in valid_buttons:
			data_strings.erase(button)

	for button in valid_buttons:
		if not data_strings.has(button):
			data_strings[button] = ""
func _get_buttons_name() -> Array[String]:
	var button_names:Array[String]
	for i in get_children():
		if i is Button:
			button_names.append(i.name)
	return button_names
#endregion
func _ready() -> void:
	if not Engine.is_editor_hint():
		_get_buttons()
		if tab_menu:
			tab_menu.key_tab_selected.connect(_on_key_changed)
			tab_menu.tab_disabled.connect(_on_tab_disabled)


func _get_buttons() -> void:
	buttons = []
	for button in get_children():
		if button is Button:
			buttons.append(button)
			button.pressed.connect(_on_buttoon_pressed.bind(button))

func _on_buttoon_pressed(button:Button) -> void:
	for bu in buttons:
		bu.button_pressed = (bu == button)
	if tab_menu:
		if data_strings.has(button):
			var tab_name:String = data_strings[button]
			var select_tab_index:int = tab_menu.find_tab_index_by_title(tab_name)
			if select_tab_index == -1:
				printerr("タブが存在しません。")
				return
			tab_menu.current_tab = select_tab_index
		else:
			print("割り当てなし")
	else:
		printerr("tab_menuが選択されていません")

func _on_key_changed(tab_name:String) -> void:
	var button:Button = data_strings.find_key(tab_name)
	if button == null:
		printerr("ボタンの割り当てが見つかりません")
		return
	for bu in buttons:
		bu.set_pressed_no_signal((bu==button))

func _on_tab_disabled(tab_name:String,dis:bool) -> void:
	var button:Button = data_strings.find_key(tab_name)
	if button == null:
		printerr("ボタンの割り当てが見つかりません")
		return
	for bu in buttons:
		if bu == button:
			bu.disabled = dis
