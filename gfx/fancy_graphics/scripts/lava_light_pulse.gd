extends PointLight2D

func _physics_process(delta: float) -> void:
	color.a = randf_range(0.2, 1.0)
