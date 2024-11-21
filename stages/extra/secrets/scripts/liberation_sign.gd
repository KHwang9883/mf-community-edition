extends Node2D

const LIBERATION_SIGN = preload("res://stages/extra/secrets/scripts/liberation_sign.tscn")
@onready var marker: Marker2D = $Marker2D

func create(upwards: bool = false) -> void:
	var keyboard = LIBERATION_SIGN.instantiate()
	Scenes.current_scene.add_child(keyboard)
	keyboard.position = marker.global_position
	keyboard.reset_physics_interpolation()
	if upwards:
		keyboard.speed.y = -300
	if SettingsManager.get_quality() == SettingsManager.QUALITY.MIN:
		keyboard.scale.y *= -1
		keyboard.default_speed_x_min = 0
		keyboard.default_speed_x_max = 0
		keyboard.speed.x = 0
