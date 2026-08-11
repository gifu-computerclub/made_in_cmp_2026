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

## キー入力で次のタブを選択したとき発行される
signal key_tab_selected(tab_name:String)

signal tab_disabled(tab_name:String,dis:bool)
## [code]true[/code]の時キー入力によるタブ変更を有効化します.
var ui_on:bool = false

## インプットマップを選択するとこのキーでタブを次に進めます。
@export var left_key:StringName
## インプットマップを選択するとこのキーでタブを前に進めます。
@export var right_key:StringName

##インスペクターを更新します。
@export_tool_button("インスペクターを更新")
var update_actions: Callable = _update_inspecter

var _actions_cache: PackedStringArray
var _enum_cache := ""
var _cache_dirty := true
#region インスペクター
func _update_cache():
	if !_cache_dirty:
		return
	_actions_cache = _get_input_actions_sorted()
	_enum_cache = ",".join(_actions_cache)
	_cache_dirty = false

func _update_inspecter() -> void:
	_cache_dirty = true
	notify_property_list_changed()
func _validate_property(property: Dictionary) -> void:
	_update_cache()
	match property.name:
		"left_key", "right_key":
			property.hint = PROPERTY_HINT_ENUM
			property.hint_string = _enum_cache
func _property_can_revert(property: StringName) -> bool:
	if property == "left_key":
		return true
	if property == "right_key":
		return true
	return false
func _property_get_revert(property: StringName) -> Variant:
	if property == "left_key":
		return &""
	if property == "right_key":
		return &""
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
	_cache_dirty = true
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
			key_tab_selected.emit(get_tab_title(current_tab))
			return
		i -= 1


func _select_next_tab() -> void:
	var max_tabs = get_tab_count()
	var i = current_tab + 1
	while i < max_tabs:
		if not is_tab_disabled(i):
			current_tab = i
			key_tab_selected.emit(get_tab_title(current_tab))
			return
		i += 1

##引数のノードの子ノードのうち一番最初の[Menu]を返します
func find_menu(node: Node) -> Menu:
	for child in node.get_children():
		if child is Menu:
			return child
		var result = find_menu(child)
		if result:
			return result
	return null

func _on_tab_container_tab_changed(tab: int) -> void:
	var current_tab := get_child(tab)
	var menu := find_menu(current_tab)
	if menu:
		menu.call_deferred("configure_focus")

## 現在開かれているタブの[Menu]の最初をフォーカスします。
func focus() -> void:
	var currented_tab = get_child(current_tab)
	var menu :Menu= find_menu(currented_tab)
	if menu:
		menu.call_deferred("configure_focus")

##　[TabMenu]内のすべての[Menu]の[SettingsData]をセットします。
func set_resouce(data:SettingsData) -> void:
	var menus:= find_children("*","Menu",true,false)
	for i in menus:
		if i is Menu:
			i.setting_data = data

## すべてのタブを名前の配列として取得します。
func get_all_tab_titles() -> Array[String]:
	var titles: Array[String] = []
	
	# タブの総数を取得してループ
	for i in range(get_tab_count()):
		titles.append(get_tab_title(i))
		
	return titles

## 線形探索でタブ名を検索します。成功したらそのインデックスを返し、失敗したら[code]-1[/code]を返します。
func find_tab_index_by_title(target_title: String) -> int:
	for i in range(get_tab_count()):
		if get_tab_title(i) == target_title:
			return i # 一致したらインデックスを返す
			
	return -1 # 見つからなかった場合

## [code]set_tab_disabled()[/code]の変わりに使用する。シグナルが発行される。
func set_tab_disable(index:int,dis:bool) -> void:
	set_tab_disabled(index,dis)
	tab_disabled.emit(get_tab_title(index),dis)
