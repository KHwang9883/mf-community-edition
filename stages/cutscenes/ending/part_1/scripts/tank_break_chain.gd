extends Area2D

func _ready():
	area_entered.connect(func(area):
		if area.is_in_group("cam_manager"):
			speed = 0
	)

var speed: float = -1.0

func _physics_process(delta):
	if speed == -1.0: return
	speed += delta * 12
	position.y += speed * delta * 50
	if position.y > 800: queue_free()
