extends Projectile

func _physics_process(delta: float) -> void:
	super(delta)
	
	sprite_node.rotation_degrees += 1000 * delta
