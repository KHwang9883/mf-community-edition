extends TextureRect

const POWERUP = preload("res://engine/objects/players/prefabs/sounds/powerup.wav")
const INCORRECT = preload("res://sfx/incorrect.wav")

func activate() -> bool:
	if Data.values.stopwatch > 0.0:
		var _sfx = CharacterManager.get_sound_replace(INCORRECT, INCORRECT, "menu_failure", false)
		Audio.play_1d_sound(INCORRECT, false, {ignore_pause = true})
		return false
	
	Data.values.stopwatch = 10.0
	var _sfx = CharacterManager.get_sound_replace(POWERUP, POWERUP, "bonus_activate", false)
	Audio.play_1d_sound(_sfx, false, {ignore_pause = true})
	return true
