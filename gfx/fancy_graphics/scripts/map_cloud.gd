extends AnimatedSprite2D

var frequency: float = 0.02
var phase: float = randf_range(0.0, 360.0)

func _physics_process(delta):
	phase = wrapf(phase + frequency * Thunder.get_delta(delta), 0, PI * 2)
	rotation_degrees = sin(phase) * 20
	scale = Vector2.ONE + Vector2.ONE * sin(phase) / 5
	
