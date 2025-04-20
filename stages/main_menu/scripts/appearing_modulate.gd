extends Node2D

@export var appear_on_ready: bool = true
@export var appearing_delay_sec: float = 0.0
@export var appearing_duration_sec: float = 2.0

func _ready() -> void:
	if appear_on_ready: appear()

func appear() -> void:
	var tw = create_tween()
	if appearing_delay_sec:
		tw.tween_interval(appearing_delay_sec)
	tw.tween_property(self, "modulate:a", 1.0, appearing_duration_sec)
