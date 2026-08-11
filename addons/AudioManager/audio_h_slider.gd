@tool
extends HSlider
class_name AudioHSlider
##Audioを変更できるスライダーです。
##
##0.0~1.0の間で使用してください。

##オーディオバスの名前を入力するとそのバスを操作します。
var bass_name:StringName = &"Master"
var _audio_value:float = 0.0

func _get_property_list() -> Array[Dictionary]:
	var buss_names:Array[String] = _get_audio_bass_names()
	var datas:Array[Dictionary]
	var enum_string:StringName = ",".join(buss_names)
	datas.append({
		"name":"bass_name",
		"type":TYPE_STRING_NAME,
		"hint":PROPERTY_HINT_ENUM,
		"hint_string":enum_string,
		"usage":PROPERTY_USAGE_EDITOR
	})
	return datas
func _ready() -> void:
	if not Engine.is_editor_hint():
		_on_slider_value_changed(value)
		value_changed.connect(_on_slider_value_changed)

func _on_slider_value_changed(value:float) -> void:
	AudioManager.set_volume_ratio(bass_name,value)
	_audio_value = value

##trueにすると音量を一時的に0にして操作を無効にします。falseにすると音量を復元して操作を有効化します。
func set_audio_disable(toggle:bool) -> void:
	AudioManager.set_volume_ratio(bass_name,_audio_value if not toggle else 0)
	editable = toggle


func _get_audio_bass_names() -> Array[String]:
	var bus_names:Array[String] = []
	for i in range(AudioServer.get_bus_count()):
		bus_names.append(AudioServer.get_bus_name(i))
	return bus_names
