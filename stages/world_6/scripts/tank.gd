extends Node2D

@export var limit: float

func _physics_process(delta: float) -> void:
	if position.x > limit:
		position.x -= delta * 30
	elif position.x < limit:
		position.x = limit
