extends Node2D

@export var KEYBOARD_EFFECT = preload("res://engine/objects/effects/brick_debris/ice_debris.tscn")

func create() -> void:
	var speeds = [Vector2(2, -8), Vector2(4, -7), Vector2(-2, -8), Vector2(-4, -7)]
	for i in speeds:
		NodeCreator.prepare_2d(KEYBOARD_EFFECT, self).create_2d(true).call_method(func(eff: Node2D):
			eff.global_transform = global_transform
			eff.velocity = i
		)
