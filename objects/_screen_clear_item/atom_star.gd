extends Powerup



func collect() -> void:
	if score > 0:
		ScoreText.new(str(score), self)
		Data.values.score += score
	
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

	var powerup_sfx = CharacterManager.get_sound_replace(pickup_powerup_sound, DEFAULT_POWERUP_SOUND, "powerup", true)
	var neutral_sfx = CharacterManager.get_sound_replace(pickup_neutral_sound, DEFAULT_NEUTRAL_SOUND, "powerup", true)
	
	if worked:
		Audio.play_sound(powerup_sfx, self, false, {pitch = sound_pitch, ignore_pause = true})
	else:
		Audio.play_sound(neutral_sfx, self, false, {pitch = sound_pitch})
	queue_free()
