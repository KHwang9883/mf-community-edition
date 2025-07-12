extends "res://engine/objects/enemies/spikes/spike.gd"

var velocity: float


func _physics_process(delta: float) -> void:
	super(delta)
	global_position += Vector2(velocity, 0).rotated(rotation) * Thunder.get_delta(delta)
