extends "res://engine/objects/detectors/player_detection.gd"

@export var id: int = 0
@export var set_timer: int = 0
@export_range(-1.0, 1.0) var set_direction: int = 0

@onready var marker_2d: Marker2D = $Marker2D

func _ready() -> void:
	if SettingsManager.get_tweak("checkpoints", true) == false:
		queue_free()
		return
	
	super()
	player_enter.connect(func():
		if id in Data.values.checked_cps:
			return
		if Data.values.checkpoint != id:
			Data.values.checkpoint = id
			if set_timer > 0:
				Data.values.time = set_timer
			if set_direction:
				Thunder._current_player.direction = set_direction
		if !id in Data.values.checked_cps:
			Data.values.checked_cps.append(id)
	)
	
	if Data.values.checkpoint == id:
		Thunder._current_player.global_position = marker_2d.global_position
		Thunder._current_player.reset_physics_interpolation()
		Thunder._current_camera.teleport()
		if set_timer > 0:
			(func():
				Data.values.time = set_timer
			).call_deferred()
