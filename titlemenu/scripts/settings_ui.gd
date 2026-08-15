extends Control
@onready var setting_player: AnimationPlayer = %SettingPlayer
@onready var tab_menu: TabMenu = %TabMenu
@onready var debug_button: AnimetionButton = %DebugButton
@onready var window_size: OptionButton = %WindowSize
@onready var full_screne: CheckButton = %FullScrene
@onready var master_slider: AudioHSlider = %MasterSlider
@onready var bgm_slider: AudioHSlider = %BGMSlider
@onready var se_slider: AudioHSlider = %SESlider
@onready var enviroment_slider: AudioHSlider = %EnviromentSlider

signal back_pressed
var ui_on:bool = false

func _ready() -> void:
	_on_debug_changed(GameManager.debug_mode)
	GameManager.debug_change.connect(_on_debug_changed)
func start_ui() -> void:
	ui_on = true
	tab_menu.ui_on = true
	tab_menu.focus()
	setting_player.play("start")

func _process(delta: float) -> void:
	if GameManager.settings.exhibition_mode:
		window_size.disabled = true
		full_screne.disabled = true
	else:
		window_size.disabled = false
		full_screne.disabled = false
func _on_setting_back_pressed() -> void:
	ui_on = false
	tab_menu.ui_on = false
	back_pressed.emit()


func _on_tab_menu_actioned(item: Control, value: Variant) -> void:
	match item.name:
		"Master":
			master_slider.set_audio_disable(not value)
		"BGM":
			bgm_slider.set_audio_disable(not value)
		"SE":
			se_slider.set_audio_disable(not value)
		"Enviroment":
			enviroment_slider.set_audio_disable(not value)
		"WindowSize":
			print("option:",value)
			var viewport_wide = [1152,1280,1920]
			var viewport_high = [628,720,1080]
			var old_size = DisplayServer.window_get_size()
			var old_pos = DisplayServer.window_get_position()
			var new_size =Vector2i(viewport_wide[value],viewport_high[value])
			# 新旧サイズの差分
			var diff = new_size - old_size
			# 中心を保つように位置を調整（左上をずらす）
			var new_pos = old_pos - diff / 2
			# 先に位置を設定 → その後サイズを設定
			DisplayServer.window_set_position(new_pos)
			DisplayServer.window_set_size(new_size)
		"FullScrene":
			if value == true:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("b") and ui_on:
		_on_setting_back_pressed()

func _on_debug_changed(value:bool) -> void:
	tab_menu.set_tab_disable(2,not value)
	debug_button.visible = value



func _on_tab_menu_request_init(item: Control) -> void:
	match item.name:
		"MasterSlider":
			item.set_audio_disable(not GameManager.settings.use_master)
		"BGMSlider":
			item.set_audio_disable(not GameManager.settings.use_bgm)
		"SESlider":
			item.set_audio_disable(not GameManager.settings.use_se)
		"EnviromentSlider":
			item.set_audio_disable(not GameManager.settings.use_enviroment)
