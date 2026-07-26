extends Button
class_name AnimetionButton
var tween:Tween

func _ready() -> void:
	offset_transform_enabled = true
	mouse_entered.connect(_hover)
	mouse_exited.connect(_unhover)
	focus_entered.connect(_hover)
	focus_exited.connect(_unhover)
	

func _hover() -> void:
	if disabled:return
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(self,"offset_transform_scale:y",1.2,0.20)
	tween.parallel().tween_property(self,"offset_transform_scale:y",1.2,0.35)
	tween.parallel().tween_property(self,"offset_transform_rotation",deg_to_rad(5.0*1.0*[-1.0,1.0].pick_random()),0.1)
	tween.parallel().tween_property(self,"offset_transform_rotation",deg_to_rad(0.0),0.1).set_delay(0.1)
	

func _unhover() -> void:
	if disabled:return
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(self,"offset_transform_scale:y",1.0,0.20)
	tween.parallel().tween_property(self,"offset_transform_scale:y",1.0,0.35)
	tween.parallel().tween_property(self,"offset_transform_rotation",deg_to_rad(0.0),0.1)
