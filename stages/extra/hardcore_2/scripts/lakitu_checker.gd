extends Area2D

const Lakitu = preload("res://engine/objects/enemies/lakitus/lakitu.gd")

@export var duration: float = 0
@export var min_time: float = 0.67
@export var max_time: float = 0.45
@export var skip_animation: bool = true

func _ready() -> void:
	area_entered.connect(func(area: Area2D):
		var body = area.get_parent()
		if body is Lakitu:
			if !is_instance_valid(body):
				return
			body.pitching_duration = duration
			body.pitching_interval_min = min_time
			body.pitching_interval_max = max_time
			body.skip_pitch_animation_delay = skip_animation
	)
