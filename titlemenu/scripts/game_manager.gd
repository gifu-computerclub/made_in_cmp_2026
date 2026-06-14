extends Control
@onready var game_over_overlay: Control = %GameOverOverlay
@onready var game_over_label: Label = %GameOverLabel
@onready var back_button: Button = %BackButton
@onready var game_clear_overlay: Control = %GameClearOverlay

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


func game_clear() -> void:
	get_tree().paused = true
	game_clear_overlay.modulate.a = 0
	game_clear_overlay.visible = true
	var tween:Tween = create_tween()
	tween.tween_property(game_clear_overlay,"modulate:a",1.0,1)
	await tween.finished
	back_button.grab_focus()
	start_button_blink()
	

func start_button_blink() -> void:
	var button_tween:Tween = create_tween().set_loops()
	button_tween.tween_property(back_button,"modulate:a",0.3,0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	button_tween.tween_property(back_button,"modulate:a",1.0,0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_back_button_pressed() -> void:
	SceneManager.change_scene("res://titlemenu/scenes/title.tscn")
	await SceneManager.fade_complete
	get_tree().paused = false
	game_clear_overlay.visible = false
