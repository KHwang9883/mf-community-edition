extends Path2D

var _curve: Curve2D


func _draw() -> void:
	var spots: PackedVector2Array = curve.get_baked_points()
	if spots.size() % 2 != 0:
		spots.resize(spots.size() - 1)
	draw_set_transform(Vector2.ZERO, -global_rotation, Vector2.ONE/global_scale)
	draw_multiline(spots, Color.PALE_VIOLET_RED, 4)


func _process(delta: float) -> void:
	if !curve || _curve == curve:
		return
	
	queue_redraw()
	_curve = curve
