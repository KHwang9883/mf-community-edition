extends Node2D

@export var speed: float = 20

func _physics_process(delta):
	rotation_degrees -= speed * delta
