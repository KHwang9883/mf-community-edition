extends Sprite2D

func _ready() -> void:
	var tw = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "scale:x", 0.8, 2.0)
	tw.tween_property(self, "scale:x", 1.0, 2.0)
