extends Node2D

const LIBERATION_SIGN = preload("res://stages/extra/secrets/scripts/liberation_sign.tscn")
@onready var marker: Marker2D = $Marker2D

func create(upwards: bool = false) -> void:
	var keyboard = LIBERATION_SIGN.instantiate()
	Scenes.current_scene.add_child(keyboard)
	keyboard.position = marker.global_position
	if upwards:
		keyboard.speed.y = -300
