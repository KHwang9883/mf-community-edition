extends GeneralMovementBody2D

func _physics_process(delta: float) -> void:
	super(delta)
	if !is_equal_approx(abs(speed.x), 50.0):
		speed.x = 50.0 * signf(speed.x)
		if speed.x == 0:
			speed.x = 50.0
