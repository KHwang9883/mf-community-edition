extends Powerup

@export var item_name: String = "atom"

func collect() -> void:
	if score > 0:
		ScoreText.new(str(score), self)
		Data.add_score(score)
	
	Data.values.item = item_name
	
	Audio.play_sound(pickup_powerup_sound, self, false, {pitch = sound_pitch, ignore_pause = true})
	queue_free()
