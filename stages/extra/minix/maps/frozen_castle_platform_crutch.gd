extends Area2D


func _physics_process(delta: float) -> void:
	var overlaps = get_overlapping_bodies()
	for body: Node2D in overlaps:
		if body is GeneralMovementBody2D && body.speed.x > 250:
			body.speed.x = -abs(body.speed.x)
			body.position.x -= 5
