extends Area2D

@export_range(-1.0, 1.0, 1.0) var left_right: int = -1


func _physics_process(delta: float) -> void:
	var overlaps = get_overlapping_bodies()
	for body: Node2D in overlaps:
		if body is GeneralMovementBody2D && (
			(body.speed.x > 250 && left_right == -1) ||
			(body.speed.x < -250 && left_right == 1)
		):
			body.speed.x = abs(body.speed.x) * left_right
			body.position.x += 5 * left_right
