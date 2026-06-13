extends Control
@onready var game_over_overlay: Control = %GameOverOverlay
@onready var game_over_label: Label = %GameOverLabel

var select_dis:Discription



func game_over() -> void:
	get_tree().paused = true
	game_over_overlay.visible = true
	game_over_overlay.position.y = -game_over_overlay.size.y
	game_over_label.rotation = 0.0
	# Tweenで降りてくる
	var tween = create_tween()
	tween.tween_property(game_over_overlay, "position:y", 0, 1.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(game_over_label, "rotation", 0.1, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await tween.finished
	await get_tree().create_timer(2.0).timeout
	SceneManager.change_scene("res://titlemenu/scenes/title.tscn")
	await SceneManager.fade_complete
	get_tree().paused = false
	game_over_overlay.visible = false
