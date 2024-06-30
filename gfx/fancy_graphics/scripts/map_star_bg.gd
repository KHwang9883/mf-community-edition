extends Node2D

func _physics_process(delta):
	rotation_degrees -= 20 * delta
