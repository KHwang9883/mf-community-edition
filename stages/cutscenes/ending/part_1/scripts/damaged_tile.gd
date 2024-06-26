extends Sprite2D

@export var speed: Vector2

func _physics_process(delta):
	speed.y += delta * 12
	position += speed * delta * 50
	rotation += delta * 16 * sign(speed.x)
	if position.y > 700: modulate.a -= delta
	if modulate.a <= 0.0: queue_free()
	
	if speed.y > 0:
		z_index = 5
