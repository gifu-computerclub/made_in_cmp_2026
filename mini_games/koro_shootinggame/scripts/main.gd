extends Node2D
signal gameclear()
@onready var timer_ui = %TimerUi
@onready var item_muzzle = $ItemMuzzle

func _ready() -> void:
	item_muzzle.ScoreAdd.connect(_on_score_add)

func _process(delta: float) -> void:
	pass

func _on_timer_ui_timeout() -> void:
	emit_signal("gameclear")
	GameManager.game_clear()

func _on_score_add() -> void:
	remove_timer(2)

func remove_timer(value:float) -> void:
	timer_ui.start(max(0.001,timer_ui.get_remiting_time()-value))
