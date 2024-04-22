extends PointLight2D

var rand_pause: float = randf_range(0.05, 0.5)

func _ready() -> void:
	await get_tree().create_timer(rand_pause, false, false, false).timeout
	var tw = create_tween().set_loops()
	tw.tween_property(self, "energy", 0.5, 0.8)
	tw.tween_property(self, "energy", 1.2, 1.0)
	var tw2 = create_tween().set_loops()
	tw2.tween_property(self, "scale", Vector2.ONE * 0.8, 0.8)
	tw2.tween_property(self, "scale", Vector2.ONE * 1.2, 1.0)
