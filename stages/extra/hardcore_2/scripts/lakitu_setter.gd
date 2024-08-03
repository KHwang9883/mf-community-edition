extends Node2D

var children: Array[Node]

func _ready() -> void:
	for i in get_children():
		if i is Node2D:
			children.append(i)


func set_min_time(to: float) -> void:
	for i in children:
		i.pitching_interval_min = to


func set_max_time(to: float) -> void:
	for i in children:
		i.pitching_interval_max = to


func set_duration(to: float) -> void:
	for i in children:
		i.pitching_duration = to


func set_skip_animation(to: bool) -> void:
	for i in children:
		i.skip_pitch_animation_delay = to
