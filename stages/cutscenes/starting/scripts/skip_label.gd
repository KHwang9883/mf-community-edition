extends "res://engine/scripts/nodes/effects/blinking_canvas_item.gd"

func _ready() -> void:
	_min_a = 0.5
	super()
	await get_tree().create_timer(3, false).timeout
	queue_free()
