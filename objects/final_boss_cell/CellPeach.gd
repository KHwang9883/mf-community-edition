extends AnimatedSprite2D

var speed: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	global_position += speed * delta
