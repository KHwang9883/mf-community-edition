extends AnimatedSprite2D

func fade_out(duration: float = 0.5) -> void:
	var tw = create_tween()
	tw.tween_property(self, "self_modulate:a", 0.0, duration)
	


func _ready() -> void:
	sprite_frames = SkinsManager.apply_player_skin(CharacterManager.get_suit("small", "" if SettingsManager.settings.skin else "Mario"))
	play(&"walk")

func _physics_process(delta: float) -> void:
	if animation != "walk":
		play("walk")
