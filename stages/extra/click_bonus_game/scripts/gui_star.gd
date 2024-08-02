extends Path2D

@onready var path_follow_2d = $PathFollow2D
var active = false

func _process(delta: float) -> void:
	if !active: return
	path_follow_2d.progress += 300 * delta
