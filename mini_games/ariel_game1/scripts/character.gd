class_name ArielGame1Character
extends CharacterBody3D

const XPOSITION:Dictionary[StringName,int] = {
	&"left": -1.5,
	&"middle": 0,
	&"right": 1.5,
}

const HITANIMATIONNAME:Dictionary[int,StringName] = {
	1:&"super",
	2:&"hyper",
	3:&"excellent",
}

signal change_health

@export var health:int = 10

var punched:bool

var _mono_tween:Tween

var main:Node3D

var combo:int = 0

@onready var punch_anim: AnimationPlayer = %PunchAnim

@onready var punch_area: Area3D = %PunchArea
@onready var sneek_anim: AnimationPlayer = %SneekAnim
@onready var timer: Timer = %Timer
@onready var punch_se: AudioStreamPlayer = %Punch
@onready var excelllent_se: AudioStreamPlayer = %Excelllent



func _ready() -> void:
	punched = false
	main = get_tree().get_first_node_in_group(&"ArielGame1Main")
	combo = 0

func _physics_process(delta: float) -> void:

	move_and_slide()

func move(pos:StringName)->void:
	if punched:
		return
	position.x = XPOSITION[pos]
	

func punch()->void:
	if punch_anim.is_playing():
		return
	punch_anim.play("punch")
	main.shaker.play_shake()
	await punch_anim.animation_finished

func sneek()->void:
	if punch_anim.is_playing():
		return
	if sneek_anim.is_playing():
		return
	sneek_anim.play("sneek")
	await sneek_anim.animation_finished

func _punching(punching:bool)->void:
	punched = punching

func _on_punch_area_body_entered(body: Node3D) -> void:
	if self.has_method(&"player"):
		if body.has_method(&"enemy"):
			body.health -= 1
			body.change_health.emit()
			if _mono_tween:
				_mono_tween.kill()
			
			combo += 1
			if not HITANIMATIONNAME.has(combo):
				combo -= 1
			if combo >= 3:
				excelllent_se.play()
			else:
				punch_se.play()
			timer.stop()
			timer.start()
			main.hit_anim.stop()
			main.hit_anim.play(HITANIMATIONNAME[combo])
			main.hit_effect.trigger_hit_at_world(
			body.global_position,
			main.camera,
			1.0
			)
			AudioManager.play_SE("res://mini_games/ariel_game1/assets/sounds/" + HITANIMATIONNAME[combo] + ".wav")
			
			
			
	elif self.has_method(&"enemy"):
		if body.has_method(&"player"):
			body.health -= 1
			body.change_health.emit()
			main.mono.show()
			if _mono_tween:
				_mono_tween.kill()
			punch_se.play()
			_mono_tween = create_tween()
			_mono_tween.tween_property(main.mono.material, "shader_parameter/intensity", 0, 0.5)\
				.from(1)\
				.set_trans(Tween.TRANS_LINEAR)\
				.set_ease(Tween.EASE_OUT)
			await _mono_tween.finished
			main.mono.hide()


func _on_timer_timeout() -> void:
	combo = 0
