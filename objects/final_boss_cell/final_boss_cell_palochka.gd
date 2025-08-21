extends Projectile

func _physics_process(delta: float) -> void:
	super(delta)
	
	sprite_node.rotation_degrees += 1000 * delta
	if global_position.y > 1000: queue_free()
