extends AnimatedSprite2D

func _ready() -> void:
	global_position.x += randi_range(32, -32)
	animation_finished.connect(queue_free)

func _physics_process(delta: float) -> void:
	global_position.y -= 50 * delta
