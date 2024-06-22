extends Node2D

@onready var sprite_2d = $Sprite2D
@export var speed: Vector2

func _physics_process(delta):
	speed.y += delta * 16
	position += speed * delta * 50
	sprite_2d.rotation += delta * 16 * sign(speed.x)
	
	if speed.y > 0:
		z_index = 5
