extends TextureRect

const CLOCK = preload("res://engine/objects/items/stopwatch/clock.tscn")
const POWERUP = preload("res://engine/objects/players/prefabs/sounds/powerup.wav")
const INCORRECT = preload("res://engine/components/ui/_sounds/incorrect.wav")

func activate() -> bool:
	if Data.values.stopwatch > 0.0:
		var _sfx2 = CharacterManager.get_sound_replace(INCORRECT, INCORRECT, "menu_failure", false)
		Audio.play_1d_sound(_sfx2, false, {ignore_pause = true})
		return false
	
	var clock = CLOCK.instantiate()
	Scenes.current_scene.add_child(clock)
	clock.activate_stopwatch()
	Data.values.stopwatch = 10.0
	var _sfx = CharacterManager.get_sound_replace(POWERUP, POWERUP, "bonus_activate", false)
	Audio.play_1d_sound(_sfx, false, {ignore_pause = true})
	return true
