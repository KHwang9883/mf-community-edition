extends Sprite2D

@export var scale_min = 0.8
@export var scale_max = 1.0

func _ready() -> void:
	var tw = create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "scale:x", scale_min, 2.0)
	tw.tween_property(self, "scale:x", scale_max, 2.0)
