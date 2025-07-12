extends Area2D

var width: float
var phase: float

var tween: Tween


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE/global_scale)
	for i in get_shape_owners():
		var spots: PackedVector2Array = shape_owner_get_owner(i).polygon
		spots.append(spots[0])
		draw_polyline(spots, Color.RED, width)


func _process(delta: float) -> void:
	width = 3 + 2 * sin(phase)
	phase = wrapf(phase + PI/8, -PI, PI)
	
	queue_redraw()
