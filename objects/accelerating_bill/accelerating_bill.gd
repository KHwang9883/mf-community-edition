extends GeneralMovementBody2D

@export_range(0, 1, 0.001, "or_greater", "hide_slider", "suffix:px/s") var acceleration: float = 1250


func _physics_process(delta: float) -> void:
	super(delta)
	
	if !is_zero_approx(speed.x):
		speed.x += signf(speed.x) * acceleration * delta
