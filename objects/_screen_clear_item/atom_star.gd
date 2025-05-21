extends Powerup

@export var item_name: String = "atom"

func collect() -> void:
	if score > 0:
		ScoreText.new(str(score), self)
		Data.add_score(score)
	
	Data.values.item = item_name
	
	var _sfx = CharacterManager.get_sound_replace(pickup_powerup_sound, DEFAULT_POWERUP_SOUND, "powerup", true)
	Audio.play_sound(_sfx, self, false, {pitch = sound_pitch, ignore_pause = true})
	queue_free()
