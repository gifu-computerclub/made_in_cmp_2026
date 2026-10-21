extends TextEdit
@export var Main: Node
@export var ItemMuzzle: Node
@onready var ScoreText: Timer = $ScoreTimer
var Score: int = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	Main.gameclear.connect(_ongameclear)
	ScoreText.timeout.connect(_on_timer_timeout)
	ItemMuzzle.ScoreAdd.connect(ScoreAdd)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_timer_timeout() -> void:
	Score = Score + 100
	text = "Score:%d" % Score
	pass

func ScoreAdd() -> void:
	Score = Score + 50
	text = "Score:%d" % Score
	pass
	
func _ongameclear() -> void:
	GameManager.game_clear(text)
	
