extends TextureRect

const HAMMER_ITEM = preload("res://objects/_hammer_item/hammer_item.tscn")

const DEFAULT_POWERUP_SOUND = preload("res://engine/objects/players/prefabs/sounds/powerup.wav")
const INCORRECT = preload("res://sfx/incorrect.wav")

func activate() -> bool:
	var worked: bool
	var pl: Player = Thunder._current_player
	if pl:
		var ham = HAMMER_ITEM.instantiate()
		ham.score = 0
		ham.appear_distance = 0
		ham.transform = pl.transform
		Scenes.current_scene.add_child(ham)
		worked = true
	
	if worked:
		var _sfx = CharacterManager.get_sound_replace(DEFAULT_POWERUP_SOUND, DEFAULT_POWERUP_SOUND, "bonus_activate", false)
		Audio.play_1d_sound(_sfx, false, {ignore_pause = true})
	else:
		var inc_sfx = CharacterManager.get_sound_replace(INCORRECT, INCORRECT, "incorrect", false)
		Audio.play_1d_sound(inc_sfx, false, {ignore_pause = true})
	
	return worked
