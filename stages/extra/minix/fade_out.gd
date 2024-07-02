extends CanvasItem

func fade_out(duration: float = 0.5) -> void:
	var tw = create_tween()
	tw.tween_property(self, "self_modulate:a", 0.0, duration)
	
