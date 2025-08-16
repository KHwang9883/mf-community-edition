extends Powerup

@export var item_name: String = "atom"

func collect() -> void:
	if score > 0:
		ScoreText.new(str(score), self)
		Data.add_score(score)
	
	Data.values.item = item_name
	Data.technical_values.custom_saved_values.item_replenisher = item_name
	
	var _sfx = CharacterManager.get_sound_replace(pickup_powerup_sound, pickup_powerup_sound, "powerup_no_transform", false)
	Audio.play_1d_sound(_sfx, false, {pitch = sound_pitch, ignore_pause = true})
	queue_free()
