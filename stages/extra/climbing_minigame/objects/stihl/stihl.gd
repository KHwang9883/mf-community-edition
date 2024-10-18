extends "res://engine/objects/enemies/spikes/spike.gd"

@export var velocity := Vector2(0, -200)
@export var rotation_speed := -100.0

func _physics_process(delta: float) -> void:
	super(delta)
	global_position += velocity * delta
	global_rotation_degrees += rotation_speed * delta
