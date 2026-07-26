@tool
class_name Menu
extends VBoxContainer
##メニュー画面を作るのに使用します。
##
##SettingDataにリソースをセットするとDataからノードとプロパティーの紐づけが行えます。[br]
##紐づけを行うとアクション実行時自動でリソースを変更し、初期化時リソースに元づいて再配置されます。



##子ノードがアクションされたときそのノードと値を返します
signal actioned(item: Control, value)
##初期化用
signal request_init(item: Control)
##ノードが必要な者の初期化
signal reqest_visible(item: Control)
##ポインターとなるノードを指定
@export var pointer: Node
##ポインターのx座標を指定
@export var pointer_offset:Vector2
##一番下のUIに行ったときにに自動で一番上に戻ります。逆も機能します。
@export var auto_wrap: bool = false
var connect_signal:bool = false
##リソース紐づけ
@export var setting_data:SettingsData:
	set(value):
		setting_data = value
		notify_property_list_changed()
@export var data_stringing: Dictionary[Control,StringName]
var data_name:Array[String]
func _get_property_list():
	var list := []
	if not setting_data:
		return list
	var enum_string := _get_setting_variable_enum()
	var data_controal:Array[Control] = get_items()
	for i in data_controal.size():
		data_name.append(data_controal[i].name)
	#print(data_name)
	for child in get_items():
		if child is Control:
			list.append({
				"name": "data/%s" % child.name,
				"type": TYPE_STRING_NAME,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": enum_string,
				"usage": PROPERTY_USAGE_EDITOR
			})
	return list
func _validate_property(property: Dictionary) -> void:
	if property.name == "data_stringing":
		property.usage = PROPERTY_USAGE_NO_EDITOR
func _property_can_revert(property: StringName) -> bool:
	for child in get_items():
		var pro_name:StringName = &"data/%s"% child.name
		if property == pro_name:
			return true
	return false
func _property_get_revert(property: StringName) -> Variant:
	for child in get_items():
		var pro_name:StringName = &"data/%s"% child.name
		if property == pro_name:
			return &""
	return null
func _get_setting_variable_enum() -> String:
	if not setting_data:
		return ""

	var names := []
	for p in setting_data.get_property_list():
		if p.usage & PROPERTY_USAGE_STORAGE:
			names.append(p.name)

	return ",".join(names)
	
func _notification(what):
	if what == NOTIFICATION_CHILD_ORDER_CHANGED:
		notify_property_list_changed()
#インスペクター再描画
func _get(property):
	if property.begins_with("data/"):
		var node_name :String= property.get_slice("/", 1)
		var ctrl := get_node_or_null(node_name) as Control
		if ctrl and data_stringing.has(ctrl):
			return data_stringing[ctrl]
		return &""
	return null
#インスペクターセット
func _set(property, value):
	if property.begins_with("data/"):
		var node_name :String= property.get_slice("/", 1)
		var ctrl := get_node_or_null(node_name) as Control
		if ctrl:
			data_stringing[ctrl] = value
			return true
	return false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	configure_focus()
	# 各子アイテムの初期化を親に依頼
	for item in get_items():
		call_deferred("emit_signal", "request_init", item)
	#print("data:",data_stringing)
	actioned.connect(_on_menu_actioned)
	request_init.connect(_on_request_inited)
# マウスホイールでスクロールしたとき
func master_init() ->void:
	for item in get_items():
		call_deferred("emit_signal", "reqest_visible", item)
func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if not visible:
		return
	get_viewport().set_input_as_handled()

	var item = get_focused_item()
	#if is_instance_valid(item) and event.is_action_pressed("ui_accept"):
		## CheckButton や HSlider に対応
		#var val = _get_item_value(item)
		#actioned.emit(item, val)

func get_items() -> Array[Control]:
	var items: Array[Control] = []
	for child in get_children():
		if not child is Control: continue
		if child is Label: continue 
		if "Heading" in child.name: continue
		if "Divider" in child.name: continue
		items.append(child)
	return items

func configure_focus() -> void:
	var items = get_items()
	for i in items.size():
		var item: Control = items[i]
		item.focus_mode = Control.FOCUS_ALL
		# ---- クリックや値変更のシグナルを拾う ----
		if connect_signal == false:
			item.mouse_entered.connect(_on_item_mouse_entered.bind(item))
			if item is CheckButton:
				item.toggled.connect(_on_item_value_changed.bind(item))
			elif item is HSlider:
				item.value_changed.connect(_on_item_value_changed.bind(item))
			elif item is OptionButton:
				item.item_selected.connect(_on_option_selected.bind(item))
			elif item is Button:
				item.pressed.connect(_on_item_activated.bind(item))
			#connect_signal = true
		# 他にも LineEdit なら text_changed などをここで追加できる
		# -------------------------------------------
		if i == 0:
			if auto_wrap:
				item.focus_neighbor_top = items[items.size()-1].get_path()
				item.focus_previous = items[items.size()-1].get_path()
			else:
				item.focus_neighbor_top = item.get_path()
				item.focus_previous = item.get_path()
			item.call_deferred("grab_focus")
		else:
			item.focus_neighbor_top = items[i-1].get_path()
			item.focus_previous = items[i-1].get_path()

		if i == items.size() - 1:
			if auto_wrap:
				item.focus_neighbor_bottom = items[0].get_path()
				item.focus_next = items[0].get_path()
			else:
				item.focus_neighbor_bottom = item.get_path()
				item.focus_next = item.get_path()
		else:
			item.focus_neighbor_bottom = items[i+1].get_path()
			item.focus_next = items[i+1].get_path()


# 現在フォーカスの取得
func get_focused_item() -> Control:
	var item = get_viewport().gui_get_focus_owner()
	return item if item in get_children() else null

func update_selection() -> void:
	var item = get_focused_item()
	if not item or not is_instance_valid(pointer):
		return
	# Menu 内のローカル座標でポインターを配置
	var y = item.global_position.y + item.get_size().y * 0.5
	pointer.global_position.y = y + pointer_offset.y
	pointer.global_position.x = global_position.x+pointer_offset.x

# キーボードでフォーカスが変わったとき
func _on_focus_changed(focused: Control) -> void:
	if not focused or not is_instance_valid(focused):
		return
	if focused in get_children():
		update_selection()
		#_scroll_to_item(focused)
# フォーカス項目が見えるようにスクロール
func _process(delta: float) -> void:
		if Engine.is_editor_hint():
			return
		update_selection()  # ポインターを更新


func _on_item_mouse_entered(item: Control) -> void:
	item.grab_focus()
	update_selection()

# ここで「値」を統一的に取得
func _get_item_value(item: Control) -> Variant:
	if item is CheckButton:
		return item.button_pressed
	elif item is HSlider:
		return item.value
	elif item is OptionButton:
		return item.selected
	else:
		# 他のボタン等は「名前」を返すなど
		return item.name
# ボタンが押された時
func _on_item_activated(item: Control) -> void:
	#print("huhahaha")
	var val:Variant = _get_item_value(item)
	actioned.emit(item, val)
# 値が変わった時（CheckButton/HSlider等）
func _on_item_value_changed(val, item: Control) -> void:
	actioned.emit(item, val)

# OptionButton 選択
func _on_option_selected(index: int, item: Control) -> void:
	# ここでは index が選ばれた値
	#print(index)
	actioned.emit(item, index)

func _on_menu_actioned(item:Control,value) -> void:
	pass
	if data_stringing.has(item):
		setting_data.set(data_stringing[item],value)
		#print(item.name+":="+ str(value))

func _on_request_inited(item:Control) -> void:
	if data_stringing.has(item):
		if item is CheckButton:
			item.button_pressed = setting_data.get(data_stringing[item])
		elif item is HSlider:
			item.value = setting_data.get(data_stringing[item])
		elif item is OptionButton:
			item.selected = setting_data.get(data_stringing[item])
