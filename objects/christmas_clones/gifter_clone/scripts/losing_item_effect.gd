extends Node2D

@export var KEYBOARD_EFFECT = preload("res://objects/christmas_clones/gifter_clone/present.tscn")

func create() -> void:
	var keyboard = KEYBOARD_EFFECT.instantiate()
	Scenes.current_scene.add_child(keyboard)
	keyboard.position = global_position
	keyboard.reset_physics_interpolation()
