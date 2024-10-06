extends GeneralMovementBody2D

func _physics_process(delta: float) -> void:
	motion_process(delta, slide)
	if turn_sprite && sprite_node && is_instance_valid(sprite_node):
		sprite_node.flip_v = speed.x > 0
	if speed.y > -50:
		sprite_node.rotation = rotate_toward(sprite_node.rotation, deg_to_rad(-60 - (60 * int(sprite_node.flip_v))), 2 * delta)
