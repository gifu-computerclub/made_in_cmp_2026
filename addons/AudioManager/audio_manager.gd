extends Node
@onready var bgm: AudioStreamPlayer = %BGM
@onready var environment: AudioStreamPlayer = %Environment
@onready var se: AudioStreamPlayer = %SE

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var label: Label = %Label

## BGMの名前を表示する際、頭に付ける文字
@export var audio_display_preffix:String = "♪～"

## BGMの名前を表示する際、終わりに付ける文字
@export var audio_display_suffix:String = "～♪"

var BGM_name:String
var bgm_position: float = 0.0


## BGMを再生する。[br][b]path:[/b] 再生したいBGMのパス。[br][b]endfade_time:[/b] 前にBGMが流れていた場合、何秒でフェードアウトするか。
## [br][b]startfade_time:[/b] 再生する際、何秒でフェードインするか。[br][b]pitch_scale:[/b] ピッチスケール。
## [br][b]display: [/b] 名前を表示するか。デフォルトではfalse。[br][b]resume:[/b] [method AudioManager.save_BGM_position]で保存したpositionで再生を再開するか。デフォルトではfalse。
## [br][b]duplicating:[/b] 同じBGMが連続した場合、最初から再生するか。デフォルトではfalse。
func play_BGM(path:String = "", endfade_time:float = 0.0, startfade_time:float = 0.0, pitch_scale:float = 1.0, display:bool = false,resume:bool = false,duplicating:bool = false) -> void:
	if bgm_tween and bgm_tween.is_valid():
		bgm_tween.kill()
	var current_path: String = " "
	if bgm.stream:
		current_path = bgm.stream.resource_path
	
	bgm.pitch_scale = abs(pitch_scale)
	
	if not duplicating and path == current_path and bgm.playing:
		return
	
	if endfade_time != 0.0:
		# フェードアウトしてから切り替え
		await _bgm_fade_out(endfade_time)

	if path == "":
		bgm.stop()
		bgm.volume_db = 0.0
		return


	bgm.stream = load(path)

	if resume and bgm_position > 0.0:
		bgm.play()
		bgm.seek(bgm_position)
	else:
		bgm.play()

	if startfade_time == 0.0:
		bgm.volume_db = 0.0
	else:
		await _bgm_fade_in(startfade_time)

	# 表示アニメ
	if display:
		await get_tree().create_timer(1.0).timeout
		if animation_player.is_playing():
			await animation_player.animation_finished
		label.text = audio_display_preffix + str(bgm.stream.resource_path.get_file().get_basename()) + audio_display_suffix
		animation_player.play(&"BGM_display")


## 現在流れているBGMの再生位置を保存。
func save_BGM_position() -> void:
	if bgm.playing:
		bgm_position = bgm.get_playback_position()


## 保存されているbGM再生位置([param bgm_position])の値を0.0にする。
func reset_BGM_position() -> void:
	bgm_position = 0.0

var bgm_tween: Tween

var environment_tween: Tween

func _bgm_fade_out(endfade_time: float) -> void:
	if bgm_tween and bgm_tween.is_valid():
		bgm_tween.kill()

	bgm_tween = create_tween()

	var start_linear := db_to_linear(bgm.volume_db)

	bgm_tween.tween_method(
		func(v:float)->void:
			if is_instance_valid(bgm):
				bgm.volume_db = linear_to_db(v),
		start_linear,
		0.0001,
		endfade_time
	)

	await bgm_tween.finished
	bgm.volume_db = -80.0


func _bgm_fade_in(startfade_time: float) -> void:
	if bgm_tween and bgm_tween.is_valid():
		bgm_tween.kill()

	bgm_tween = create_tween()

	var start_linear := 0.0001
	var end_linear := 1.0

	bgm.volume_db = linear_to_db(start_linear)

	bgm_tween.tween_method(
		func(v:float)->void:
			if is_instance_valid(bgm):
				bgm.volume_db = linear_to_db(v),
		start_linear,
		end_linear,
		startfade_time
	)
	await bgm_tween.finished


## 効果音を再生する。[br][b]path:[/b] 再生したいBGMのパス。[br][b]pitch_scale:[/b] ピッチスケール。
func play_SE(path:String,pitch_scale:float = 1.0) -> void:
	se.stream = load(path)
	se.pitch_scale = pitch_scale
	se.play()


## 環境音を再生する。[br][b]path:[/b] 再生したいBGMのパス。[br][b]endfade_time:[/b] 前にBGMが流れていた場合、何秒でフェードアウトするか。
## [br][b]startfade_time:[/b] 再生する際、何秒でフェードインするか。[br][b]pitch_scale:[/b] ピッチスケール。
func play_environment(path:String = "",endfade_time:float = 0.0,startfade_time:float = 0.0,pitch_scale:float = 1.0) -> void:
	if environment_tween and environment_tween.is_valid():
		environment_tween.kill()
	var current_path: String = " "
	if environment.stream:
		current_path = environment.stream.resource_path
	
	environment.pitch_scale = abs(pitch_scale)
	
	if path == current_path and environment.playing:
		return
	
	if endfade_time != 0.0:
		# フェードアウトしてから切り替え
		await _environment_fade_out(endfade_time)

	if path == "":
		environment.stop()
		environment.volume_db = 0.0
		return


	environment.stream = load(path)

	environment.play()

	if startfade_time == 0.0:
		environment.volume_db = 0.0
	else:
		await _environment_fade_in(startfade_time)




func _environment_fade_out(endfade_time:float) -> void:
	if environment_tween and environment_tween.is_valid():
		environment_tween.kill()

	environment_tween = create_tween()

	var start_linear := db_to_linear(environment.volume_db)

	environment_tween.tween_method(
		func(v:float)->void:
			if is_instance_valid(environment):
				environment.volume_db = linear_to_db(v),
		start_linear,
		0.0001,
		endfade_time
	)

	await environment_tween.finished
	environment.volume_db = -80.0

func _environment_fade_in(startfade_time:float) -> void:
	if environment_tween and environment_tween.is_valid():
		environment_tween.kill()

	environment_tween = create_tween()

	var start_linear := 0.0001
	var end_linear := 1.0

	environment.volume_db = linear_to_db(start_linear)

	environment_tween.tween_method(
		func(v:float)->void:
			if is_instance_valid(environment):
				environment.volume_db = linear_to_db(v),
		start_linear,
		end_linear,
		startfade_time
	)
	await environment_tween.finished

##指定したオーディオバスの音量を0.0~1.0で指定します。
##[br]使用例:[codeblock]
##func _ready() -> void:
##    AudioManager.set_volume_ratio(&"Master",0.5)
##[/codeblock]
func set_volume_ratio(bs_name:StringName,value:float) -> void:
	var audio_bus_id = AudioServer.get_bus_index(bs_name)
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(audio_bus_id,db)
