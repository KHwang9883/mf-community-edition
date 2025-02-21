extends "res://engine/objects/players/player.gd"

func _ready() -> void:
	var _fal = CharacterManager.get_voice_line("fall_death")
	death_music_override = _fal[randi_range(0, len(_fal) - 1)]
	super()


func hurt(tags: Dictionary = {}) -> void:
	if !suit || debug_god || is_hurting:
		return
	if !tags.get(&"hurt_forced", false) && (is_invincible() || completed || warp > Warp.NONE):
		return
	if warp != Warp.NONE: return
	is_hurting = true

	if suit.gets_hurt_to:
		if ProfileManager.current_profile.data.get("mario_forever_expert"):
			change_suit(CharacterManager.get_suit("small", "Mario"), false, false)
		else:
			change_suit(suit.gets_hurt_to)
		invincible.call_deferred(tags.get(&"hurt_duration", 2))
		Audio.play_sound(suit.sound_hurt, self, false, {pitch = suit.sound_pitch, ignore_pause = true})
	else:
		die(tags)

	damaged.emit()


func die(tags: Dictionary = {}) -> void:
	if warp != Warp.NONE: return
	if debug_god: return
	if is_dying: return
	is_dying = true

	if death_stop_music:
		Audio.stop_all_musics()
	Audio.play_music(
		suit.sound_death if !death_music_override else death_music_override,
		1 if death_stop_music else 2,
		{pitch = suit.sound_pitch} if !death_music_ignore_pause else {
			pitch = suit.sound_pitch,
			ignore_pause = true
		}
	)

	var _db: Node2D
	if death_body:
		_db = NodeCreator.prepare_2d(death_body, self).bind_global_transform().call_method(
			func(db: Node2D) -> void:
				db.wait_time = death_wait_time
				db.check_for_lives = death_check_for_lives
				db.jump_to_scene = death_jump_to_scene
				if death_sprite:
					var dsdup: Node2D = death_sprite.duplicate()
					var character_death_sprite = CharacterManager.get_misc_texture("death")
					if character_death_sprite:
						dsdup.texture = character_death_sprite
					db.add_child(dsdup)
					dsdup.visible = true
		).create_2d().get_node()

	died.emit()
	died_with_body.emit(_db)
	queue_free()
