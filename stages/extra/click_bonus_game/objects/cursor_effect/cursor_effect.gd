extends Sprite2D


func _ready() -> void:
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	tw.finished.connect(queue_free)
