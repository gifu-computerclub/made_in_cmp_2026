
extends CanvasLayer

@export var duration: float = 0.38

@onready var color_rect: ColorRect = %ColorRect


var shader_mat: ShaderMaterial
var elapsed: float = 0.0
var effect_power: float = 0.0
var clock: float = 0.0
var playing: bool = false


func _ready() -> void:
	# 他のノードとMaterialを共有しないようにする
	color_rect.material = color_rect.material.duplicate()
	shader_mat = color_rect.material as ShaderMaterial

	# 画面全体を覆う
	color_rect.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var size := get_viewport().get_visible_rect().size
	shader_mat.set_shader_parameter("screen_size", size)


func trigger_hit(
	screen_uv: Vector2 = Vector2(0.5, 0.5),
	power: float = 1.0
) -> void:
	# screen_uvは0～1の画面内座標
	shader_mat.set_shader_parameter(
		"hit_center",
		screen_uv.clamp(Vector2.ZERO, Vector2.ONE)
	)

	effect_power = clampf(power, 0.0, 1.5)
	elapsed = 0.0
	playing = true

	shader_mat.set_shader_parameter("effect_amount", effect_power)
	shader_mat.set_shader_parameter("wave_progress", 0.0)


func trigger_hit_at_world(
	world_position: Vector3,
	camera: Camera3D,
	power: float = 1.0
) -> void:
	# 3Dのワールド座標を画面座標に変換
	var viewport_size := camera.get_viewport().get_visible_rect().size
	var screen_pos := camera.unproject_position(world_position)
	var uv := screen_pos / viewport_size

	trigger_hit(uv, power)


func _process(delta: float) -> void:
	clock += delta
	shader_mat.set_shader_parameter("effect_time", clock)

	if not playing:
		return

	elapsed += delta
	var t := clampf(elapsed / duration, 0.0, 1.0)

	# 最初が強く、短時間で減衰する
	var envelope := pow(1.0 - t, 1.5)

	shader_mat.set_shader_parameter(
		"effect_amount",
		effect_power * envelope
	)
	shader_mat.set_shader_parameter("wave_progress", t)

	if t >= 1.0:
		playing = false
		shader_mat.set_shader_parameter("effect_amount", 0.0)
