extends AnimatedSprite2D

@export var to_dir: int = 1

func _process(delta: float) -> void:
	visible = get_parent().dir == to_dir
