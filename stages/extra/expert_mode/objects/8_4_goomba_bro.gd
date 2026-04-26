extends "res://engine/objects/enemies/hammer_bros/goomba_bro.gd"

func _physics_process(delta: float) -> void:
	super(delta)
	if (speed.x < 0 && position.x < -32) || (speed.x > 0 && position.x > 640 + 32):
		queue_free()

func _on_walk_timeout() -> void:
	#_dir *= -1
	_radius = Thunder.rng.get_randf_range(moving_radius_min, moving_radius_max)
	_duration = Thunder.rng.get_randf_range(moving_duration_min, moving_duration_max)
	_step_moving = 1
	#vel_set_x(_speed * _dir)
