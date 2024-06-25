extends Sprite2D

var speed = -80

@onready var y = global_position.y

func _physics_process(delta: float) -> void:
	if global_position.y > y:
		speed = -80
	
	speed += 120 * delta
	global_position.y += speed * delta
