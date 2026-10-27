@tool
extends StartOverlay

signal music_started()
func start_countdown()-> void:
	if use_paused:
		await get_tree().process_frame
		_paused()
	visible = true
	GameManager.long_start = GameManager.settings.long_start
	AudioManager.play_BGM("res://mini_games/takasou_game1/assets/音律ヘブンメインソング~耳deノリノリ~.ogg",0,0,1,true)
	music_started.emit()
	await _show_countdown("Music Start!!",Color(0,1,1),1.4,0.2)
	await _show_countdown("3",Color(0,1,0),0.2,0.2)
	await _show_countdown("2",Color(1,0.5,0),0.2,0.2)
	await _show_countdown("1",Color(1,0,0),0.2,0.2)
	await _show_countdown("スタート！",Color(1,0,0),0.2,0.2)
	
	overlay.visible = false
	if title_slide:
		var tween = create_tween().set_parallel()
		tween.tween_property(title_label,"position",after_position,0.1).set_ease(Tween.EASE_OUT)
		tween.tween_property(self,"_tite_size",after_size,0.1).set_ease(Tween.EASE_OUT)
		tween.tween_property(self,"_outline",after_outline,0.1).set_ease(Tween.EASE_OUT)
		await tween.finished
	else:
		title_label.visible = false
	get_tree().paused = false
	game_start.emit()
