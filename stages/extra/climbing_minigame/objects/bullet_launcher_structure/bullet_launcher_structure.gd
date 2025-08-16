extends Node2D

signal out_of_screen

@export var top_size_y: float = 64
var _notified: bool = false

func _physics_process(delta: float) -> void:
	if !_notified:
		if global_position.y > 432 + top_size_y:
			_notified = true
			out_of_screen.emit()
	elif global_position.y > 496 + top_size_y:
		queue_free()
