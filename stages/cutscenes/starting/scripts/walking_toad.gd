extends AnimatedSprite2D

@export var speed = 50
@export var flip_enabled = true

func _physics_process(delta: float) -> void:
	global_position.x += speed * delta
	if flip_enabled:
		flip_h = speed < 0
