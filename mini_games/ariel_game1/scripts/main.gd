extends Node3D
@onready var start_overlay: StartOverlay = %StartOverlay
@onready var camera: Camera3D = %Camera
@onready var mono_cam: Camera3D = %MonoCam
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var player: CharacterBody3D = %Player
@onready var timer_ui: TimerUi = %TimerUi
@onready var mono: SubViewportContainer = %Mono
@onready var hit_effect: CanvasLayer = %HitEffect
@onready var shaker: ShakerComponent3D = %Shaker
@onready var hit_anim: AnimationPlayer = %HitAnim
@onready var enemy: Enemy = %Enemy
@onready var player_hp: ProgressBar = %PlayerHP
@onready var enemy_hp: ProgressBar = %EnemyHP



func _ready() -> void:
	animation_player.play(&"start")
	player.set_process_unhandled_input(false)
	enemy.set_process(false)
	start_overlay.game_start.connect(_on_started)
	var host:PhantomCameraHost = PhantomCameraHost.new()
	
	await get_tree().process_frame
	camera.add_child(host)
	mono.hide()

func _physics_process(_delta: float) -> void:
	mono_cam.global_transform = camera.global_transform

func _on_started()->void:
	player.set_process_unhandled_input(true)
	enemy.set_process(true)
	timer_ui.start()

func _on_timer_ui_timeout() -> void:
	GameManager.game_over()
