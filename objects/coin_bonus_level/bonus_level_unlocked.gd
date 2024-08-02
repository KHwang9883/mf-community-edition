extends Sprite2D

func activate() -> void:
	await get_tree().create_timer(4.0, false).timeout
	create_tween().tween_property(self, "modulate:a", 0.0, 1.0)
