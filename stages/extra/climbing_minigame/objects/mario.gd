extends "res://engine/objects/players/player.gd"

func _ready() -> void:
	var _fal = CharacterManager.get_voice_line("fall")
	death_music_override = _fal[randi_range(0, len(_fal) - 1)]
	super()

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
		{pitch = suit.sound_pitch} if !death_music_ignore_pause && !_suit_pause_tweak else {
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
