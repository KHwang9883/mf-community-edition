extends PathFollow2D

@export var speed: float = 60
@export var reverse: bool = false

func _physics_process(delta: float) -> void:
	progress += speed * delta
	
	if reverse && (progress_ratio >= 1 || progress_ratio <= 0):
		speed = -speed
