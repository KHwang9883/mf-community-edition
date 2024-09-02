extends GeneralMovementBody2D

var _tim: float

func _physics_process(delta: float) -> void:
	super(delta)
	
	if is_on_floor():
		if _tim > 0.3:
			_tim = 0
			jump(250)
			sprite_node.play("jump")
			return
		sprite_node.animation = "default"
		_tim += delta
	elif speed.y > 0:
		sprite_node.animation = "default"
