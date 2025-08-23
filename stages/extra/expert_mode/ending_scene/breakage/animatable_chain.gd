extends AnimatableBody2D

var speed: float = -1.0

func activate() -> void:
	speed = 0

func _physics_process(delta):
	if speed == -1.0: return
	speed += delta * 12
	position.y += speed * delta * 50
	if position.y > 800: queue_free()
