extends TextureRect

@export var suit_name: String = "boomerang"
const DEFAULT_POWERUP_SOUND = preload("res://engine/objects/players/prefabs/sounds/powerup.wav")
const INCORRECT = preload("res://sfx/incorrect.wav")

func activate() -> bool:
	var worked: bool
	
	var player: Player = Thunder._current_player
	if player && player.suit && player.suit.name != suit_name:
		player.change_suit(CharacterManager.get_suit(suit_name), true, true)
		worked = true
	
	var powerup_sfx = CharacterManager.get_sound_replace(DEFAULT_POWERUP_SOUND, DEFAULT_POWERUP_SOUND, "bonus_activate", false)
	var inc_sfx = CharacterManager.get_sound_replace(INCORRECT, INCORRECT, "menu_failure", false)
	
	if worked:
		Audio.play_1d_sound(powerup_sfx, false, {ignore_pause = true})
	else:
		Audio.play_1d_sound(inc_sfx, false, {ignore_pause = true})
	
	return worked
