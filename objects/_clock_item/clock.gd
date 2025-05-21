extends Powerup

@export var active_for_sec: float = 10.0

func collect() -> void:
	if score > 0:
		ScoreText.new(str(score), self)
		Data.add_score(score)
	
	Data.values.stopwatch = active_for_sec

	var powerup_sfx = CharacterManager.get_sound_replace(pickup_powerup_sound, DEFAULT_POWERUP_SOUND, "bonus_activate", false)

	Audio.play_sound(powerup_sfx, self, false, {pitch = sound_pitch, ignore_pause = true})
	queue_free()
