extends Node2D

var speed: float = 0

func _physics_process(delta: float) -> void:
	global_position.y -= speed * delta
