extends PathFollow2D

@export_category("Easy Platform")
@export var speed: float = 100

var dir: int


func _ready() -> void:
	dir = sign(speed)
	rotates = false


func _physics_process(delta: float) -> void:
	progress += speed * delta * dir
	if (dir > 0 && progress_ratio >= 1) || (dir < 0 && progress_ratio <= 0):
		dir *= -1
