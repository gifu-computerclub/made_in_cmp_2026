extends Node2D

var judge_timer_start : bool = false
var start_time_msec : int =0
var judge :int = 0
@onready var start_sound: AudioStreamPlayer = $start
var normal_volume: float
var change_time: float 
@export var win_time:float = 0

func _ready() -> void:
	$GO.hide()
	$otetuki.hide()
	$youwin.hide()
	$youlose.hide()
	start_sound.play()
	normal_volume = GameManager.settings.bgm_vol
	var tween:Tween = create_tween()
	tween.tween_method(_set_value,normal_volume,0.0,1.5)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("a"):
		judge_button()

func _set_value(val:float) -> void:
	AudioManager.set_volume_ratio(&"BGM",val)

func _on_timer_ui_timeout() -> void:
	GameManager.game_over()


func _on_audio_stream_player_finished() -> void:
	var random_wait_time := randf_range(1.0 , 5.0)
	$RandomTimer.start(random_wait_time)


func _on_random_timer_timeout() -> void:
	$judgeTimer.start()
	start_judge_timer()
	$GO.show()
	
func start_judge_timer() -> void:
	judge_timer_start = true
	start_time_msec = Time.get_ticks_msec()
	
func judge_button() -> void:
	if not judge_timer_start:
		finish_judgement()
		return
		
	change_time = (
		Time.get_ticks_msec() - start_time_msec
	) / 1000.0
	
	if change_time <= win_time:
		judge = 1
	else:
		judge = 2
		
	finish_judgement()

func finish_judgement() -> void:
	if judge == 0:
		$otetuki.show()
		start_sound.stop()
		$WaitTimer.start()
		
	elif judge == 1:
		$GO.hide()
		$youwin.show()
		$WaitTimer.start()

		
	
	else:
		$GO.hide()
		$youlose.show()
		$WaitTimer.start()
	
	
func _on_wait_timer_timeout() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var tween:Tween = create_tween()
	tween.tween_method(_set_value,0.0,normal_volume,1.5)
	if judge == 1:
		GameManager.game_clear("あなたの記録:　%.2f" %change_time)
	else:
		GameManager.game_over()
	
