extends Sprite2D

func activate() -> void:
	visible = true
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 1.0).from(0.0)
	await get_tree().create_timer(4.0, false).timeout
	create_tween().tween_property(self, "modulate:a", 0.0, 1.0)
