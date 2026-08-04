extends Node2D

@export var KEYBOARD_EFFECT = preload("res://engine/objects/effects/brick_debris/ice_debris.tscn")

func create() -> void:
	var speeds = [Vector2(2, -8), Vector2(4, -7), Vector2(-2, -8), Vector2(-4, -7)]
	for i in speeds:
		NodeCreator.prepare_2d(KEYBOARD_EFFECT, self).create_2d(false).call_method(func(eff: Node2D):
			eff.global_transform = global_transform
			eff.position += Vector2(0, 16).rotated(eff.rotation)
			eff.velocity = i
		)
