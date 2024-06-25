extends PathFollow2D

@export var speed: float = 0

func _physics_process(delta: float) -> void:
	progress += speed * delta
	global_position = global_position.round()
