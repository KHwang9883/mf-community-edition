extends TextureRect

const DEFAULT_POWERUP_SOUND = preload("res://engine/objects/players/prefabs/sounds/powerup.wav")
const INCORRECT = preload("res://sfx/incorrect.wav")

func activate() -> bool:
	var worked: bool
	for i in get_tree().get_nodes_in_group(&"end_level_sequence"):
		if i is Projectile:
			if i.belongs_to == Data.PROJECTILE_BELONGS.PLAYER:
				continue
			i.queue_free()
			continue
		if !i.get(&"_center"): continue
		if !Thunder.view.is_getting_closer(i._center, 32):
			continue
		
		if i.killing_enabled:
			i.got_killed("boomerang", [], false)
			worked = true

	var powerup_sfx = CharacterManager.get_sound_replace(DEFAULT_POWERUP_SOUND, DEFAULT_POWERUP_SOUND, "bonus_activate", false)
	var inc_sfx = CharacterManager.get_sound_replace(INCORRECT, INCORRECT, "menu_failure", false)

	if worked:
		Audio.play_1d_sound(powerup_sfx, false, {ignore_pause = true})
	else:
		Audio.play_1d_sound(inc_sfx, false, {ignore_pause = true})
	
	return worked
