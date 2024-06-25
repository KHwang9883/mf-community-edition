extends ColorRect

var out: bool = false
@export var speed: Vector2 = Vector2(-1200, 0)

func _physics_process(delta: float) -> void:
	if out:
		global_position += speed * delta
