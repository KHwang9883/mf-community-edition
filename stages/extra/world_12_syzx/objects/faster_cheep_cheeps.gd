extends Node2D

@export var to_speed: float = 90
@export var to_speed_blue: float = 80

func activate() -> void:
	for i in get_children():
		if "speed" in i && i.speed is Vector2:
			i.speed.x = to_speed_blue
		if "tracking_speed" in i:
			i.tracking_speed = to_speed
