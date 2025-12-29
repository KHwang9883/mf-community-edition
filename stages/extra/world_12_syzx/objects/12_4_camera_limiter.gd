extends Node

@onready var camera: Camera2D = $".."


func activate() -> void:
	camera.limit_bottom = int(camera.get_screen_center_position().y) + 240
