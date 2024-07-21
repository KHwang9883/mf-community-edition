extends "res://engine/scripts/nodes/general_movement/circle_movement.gd"

var velocity: Vector2

func _physics_process(delta: float) -> void:
	super(delta)
	
	center += velocity * Thunder.get_delta(delta)
