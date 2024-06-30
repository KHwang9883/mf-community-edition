extends Sprite2D

@export var amplitude: Vector2 = Vector2(0, 10)
@onready var center: Vector2 = position
var phase: float

func _physics_process(delta):
	position = Thunder.Math.oval(center, amplitude, deg_to_rad(phase))
	phase = wrapf(phase + 2 * Thunder.get_delta(delta), -180, 0)
