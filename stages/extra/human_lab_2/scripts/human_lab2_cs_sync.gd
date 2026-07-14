extends AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var speed: float = SettingsManager.settings.get("game_speed", 1.0)
	speed_scale = 1.2 if speed == 1.0 else 1.0
