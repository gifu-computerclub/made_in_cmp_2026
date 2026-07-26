@tool
class_name TabMenu
extends TabContainer
##設定画面のタブを作るのに使用します。  
##
##[Menu]ノードをこのノードのどこかに配置して使用します。  
##タブ切り替え用のキーをインスペクターから割り当てることができます。  

##[Menu]の子ノードがアクションされたときそのノードと値を返します
signal actioned(item: Control, value)
##初期化用
signal request_init(item: Control)
##ノードが必要な者の初期化
signal reqest_visible(item: Control)


var ui_on:bool = false
var left_key:StringName = &"tab_left"
var right_key:StringName = &"tab_right"

#region インスペクター
func _get_property_list() -> Array[Dictionary]:
	var propaty:Array[Dictionary]
	var input_map:Array[String] = _get_input_actions_sorted()
	var enum_str :StringName= ",".join(input_map)
	propaty.append({
		"name":"left_key",
		"type":TYPE_STRING_NAME,
		"hint":PROPERTY_HINT_ENUM,
		"hint_string":enum_str,
		"usage":PROPERTY_USAGE_EDITOR
	})
	propaty.append({
		"name":"right_key",
		"type":TYPE_STRING_NAME,
		"hint":PROPERTY_HINT_ENUM,
		"hint_string":enum_str,
		"usage":PROPERTY_USAGE_EDITOR
	})
	return propaty
func _property_can_revert(property: StringName) -> bool:
	if property == "left_key":
		return true
	if property == "right_key":
		return true
	return false
func _property_get_revert(property: StringName) -> Variant:
	if property == "left_key":
		return &"tab_left"
	if property == "right_key":
		return &"tab_right"
	return null
func _get_input_actions_sorted() -> Array[String]:
	var custom :Array[String]= []
	var ui :Array[String]= []

	for p in ProjectSettings.get_property_list():
		if p.name.begins_with("input/"):
			var action :String= p.name.replace("input/", "")
			if action.begins_with("ui_"):
				ui.append(action)
			else:
				custom.append(action)

	custom.sort()
	ui.sort()
	return custom + ui
#endregion
func _ready() -> void:
	notify_property_list_changed()
	if Engine.is_editor_hint():
		return
	tab_changed.connect(_on_tab_container_tab_changed)
	var menus:= find_children("*","Menu",true,false)
	for i in menus:
		if i is Menu:
			i.actioned.connect(func(item:Control,value:Variant):actioned.emit(item,value))


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if not ui_on:
		return
	if event.is_action_pressed(left_key):
		_select_prev_tab()
	elif event.is_action_pressed(right_key):
		_select_next_tab()


func _select_prev_tab() -> void:
	var i = current_tab - 1
	while i >= 0:
		if not is_tab_disabled(i):
			current_tab = i
			return
		i -= 1


func _select_next_tab() -> void:
	var max_tabs = get_tab_count()
	var i = current_tab + 1
	while i < max_tabs:
		if not is_tab_disabled(i):
			current_tab = i
			return
		i += 1

func find_menu(node: Node) -> Menu:
	for child in node.get_children():
		if child is Menu:
			return child
		var result = find_menu(child)
		if result:
			return result
	return null

func _on_tab_container_tab_changed(tab: int) -> void:
	#AudioManager.play_SE("res://assets/sound/select.mp3")
	var current_tab = get_child(tab)
	var menu :Menu= find_menu(current_tab)
	if menu:
		menu.configure_focus()
func focus() -> void:
	var currented_tab = get_child(current_tab)
	var menu :Menu= find_menu(currented_tab)
	if menu:
		menu.call_deferred("configure_focus")

func set_resouce(data:SettingsData) -> void:
	var menus:= find_children("*","Menu",true,false)
	for i in menus:
		if i is Menu:
			i.setting_data = data
