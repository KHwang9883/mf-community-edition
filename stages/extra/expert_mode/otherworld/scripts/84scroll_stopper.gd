extends Node

@onready var path_follow_2d: PathFollow2D = $".."
@onready var spike_ceiling: VBoxContainer = $"../../../Parallax2D/SpikeCeiling"

func _physics_process(delta: float) -> void:
	if spike_ceiling._state == 3:
		path_follow_2d.speed = 0
	else:
		if !is_instance_valid(Thunder._current_player): return
		if path_follow_2d.speed < 50:
			path_follow_2d.speed += 100 * delta
		else:
			path_follow_2d.speed = 50
