extends GravityBody2D

func _ready() -> void:
	if !_fancy_effects_enabled():
		if is_zero_approx(speed.x):
			speed.x = [-1, 1].pick_random() * randf_range(50, 125)
		scale.y = -scale.y
		speed.y /= 1.5
		speed.x /= 2
		gravity_scale /= 2.5
	var tw: Tween = create_tween()
	tw.tween_interval(6)
	tw.tween_property(self, ^"modulate:a", 0, 0.5)
	tw.tween_callback(queue_free)


func _physics_process(delta: float) -> void:
	motion_process(delta)
	
	if !Thunder.view.screen_dir(global_position, get_global_gravity_dir(), 512):
		queue_free()


func _fancy_effects_enabled() -> bool:
	return SettingsManager.settings.quality != SettingsManager.QUALITY.MIN
