extends AnimatedSprite2D

@export var speed = 50

func _physics_process(delta: float) -> void:
	global_position.x += speed * delta
	flip_h = speed < 0
