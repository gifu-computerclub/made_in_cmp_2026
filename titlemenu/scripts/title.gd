extends Control

@onready var shutter: TextureRect = %Shutter
@onready var title_label: RichTextLabel = %TitleLabel
@onready var main_player: AnimationPlayer = %MainPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var setting_player: AnimationPlayer = %SettingPlayer
@onready var grades: VBoxContainer = %Grades
@onready var mode_player: AnimationPlayer = %ModePlayer


func _ready() -> void:
	AudioManager.play_BGM()
	_set_menbers()
	await get_tree().create_timer(0.5).timeout
	main_player.play("start")
	GameManager.debug_change.connect(_on_debug_changed)
	_on_debug_changed(GameManager.debug_mode)
	pass


func _process(delta: float) -> void:
	return
	if Input.is_action_just_pressed("a"):
		title_label.visible = false
		var tween:Tween = create_tween()
		tween.tween_property(shutter,"scale",Vector2(1,0.1),1).set_ease(Tween.EASE_OUT)
		await tween.finished
		SceneManager.change_scene("res://titlemenu/scenes/stage_select.tscn",{"color":Color(1.0, 1.0, 1.0, 1.0)})

func _set_menbers() -> void:
	var datas:Array[Description] = GameManager.load_description()
	var grade_datas:Dictionary[int,Array] = {}
	var menbers_container:Array[VBoxContainer]
	for i in datas:
		if !grade_datas.has(i.grade + 1):
			grade_datas[i.grade + 1] = []
		print(i.grade + 1,i.game_name)
		grade_datas[i.grade + 1].append(i)
	print(grade_datas)
	for i in grades.get_children():
		if i is MenberContainer:
			var data:Array[Description]
			if !grade_datas.has(i.grade): continue
			print(i.grade)
			for j in grade_datas[i.grade]:
				if j is Description:
					data.append(j)
			i.set_menbers(data)
	

#region シグナル
func _on_start_pressed() -> void:
	animation_player.play("mode_select")
	mode_player.play("mode_select")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	animation_player.play("setting")
	setting_player.play("start")


func _on_setting_back_pressed() -> void:
	animation_player.play_backwards("setting")
	main_player.play("start")


func _on_credit_back_pressed() -> void:
	animation_player.play_backwards("credits")
	main_player.play("start")


func _on_credits_pressed() -> void:
	animation_player.play("credits")


func _on_menbers_back_pressed() -> void:
	animation_player.play_backwards("menbers")
	main_player.play("start")


func _on_menbers_pressed() -> void:
	animation_player.play("menbers")


func _on_back_pressed() -> void:
	animation_player.play_backwards("mode_select")
	main_player.play("start")


func _on_single_game_pressed() -> void:
	mode_player.play_backwards("mode_select")
	await mode_player.animation_finished
	var tween:Tween = create_tween()
	tween.tween_property(shutter,"scale",Vector2(1,0.1),1).set_ease(Tween.EASE_OUT)
	await tween.finished
	SceneManager.change_scene("res://titlemenu/scenes/stage_select.tscn",{"color":Color(1.0, 1.0, 1.0, 1.0)})

func _on_debug_changed(value:bool) -> void:
	print(value)
	if value:
		mode_player.play("debug")
		await mode_player.animation_finished
		%SingleGame.visible = false
		%DebugGame.visible = true
	else:
		mode_player.play_backwards("debug")
		await mode_player.animation_finished
		%SingleGame.visible = true
		%DebugGame.visible = false

func _on_serial_game_pressed() -> void:
	mode_player.play_backwards("mode_select")
	await mode_player.animation_finished
	var tween:Tween = create_tween()
	tween.tween_property(shutter,"scale",Vector2(1,0.1),1).set_ease(Tween.EASE_OUT)
	await tween.finished
	SceneManager.change_scene("res://titlemenu/scenes/staeg_select_new.tscn",{"color":Color(1.0, 1.0, 1.0, 1.0)})

#endregion
