extends ParallaxLayer

@export var speed: Vector2 = Vector2(-333, 0)

func _physics_process(delta: float) -> void:
	motion_offset += speed * delta
