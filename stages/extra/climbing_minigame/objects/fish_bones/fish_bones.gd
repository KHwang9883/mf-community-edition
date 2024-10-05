extends GeneralMovementBody2D


func _physics_process(delta: float) -> void:
	super(delta)
	sprite_node.rotation_degrees = clampf(-speed.y / 5, -90, 90) + 45
