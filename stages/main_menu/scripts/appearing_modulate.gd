extends CanvasItem

@export var appear_on_ready: bool = true
@export var appearing_delay_sec: float = 0.0
@export var appearing_duration_sec: float = 2.0
@export var final_modulate: float = 1.0
@export var no_appear_on_min_quality: bool = false

func _ready() -> void:
	if appear_on_ready:
		if SettingsManager.get_quality() == SettingsManager.QUALITY.MIN && no_appear_on_min_quality:
			modulate.a = final_modulate
			return
		modulate.a = 0
		appear()

func appear() -> void:
	var tw = create_tween()
	if appearing_delay_sec:
		tw.tween_interval(appearing_delay_sec)
	tw.tween_property(self, "modulate:a", final_modulate, appearing_duration_sec)
