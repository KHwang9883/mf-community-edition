extends Player

var lives: int = 1

signal damaged_to(lives: int)

func _ready() -> void:
	Thunder._current_player_state_path = ""
	Thunder._current_player_state = CharacterManager.get_suit("small", "Mario")
	super()
	_suit_pause_tweak = false


func hurt(tags: Dictionary = {}, callable = null) -> void:
	if !suit:
		return
	if !tags.get(&"hurt_forced", false) && (is_invincible() || completed || warp > Warp.NONE):
		return
	if warp != Warp.NONE: return
	
	if lives > 0:
		lives -= 1
		#change_suit(suit.gets_hurt_to)
		damaged_to.emit(lives)
		invincible(tags.get(&"hurt_duration", 2))
		Audio.play_sound(suit.sound_hurt, self, false, {pitch = suit.sound_pitch})
	else:
		die(tags)
		Scenes.custom_scenes.minix_node.current_map.coin_timer.stop()
	
	damaged.emit()


func die(tags: Dictionary = {}, callable = null) -> void:
	if warp != Warp.NONE: return
	if debug_god: return
	if is_dying: return
	is_dying = true

	if death_stop_music:
		Audio.stop_all_musics()
	Audio.play_music(
		suit.sound_death if !death_music_override || force_override_death_sound else death_music_override,
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
					var character_death_sprite = CharacterManager.get_misc_texture("death", "Mario")
					if character_death_sprite:
						dsdup.texture = character_death_sprite
					db.add_child(dsdup)
					dsdup.visible = true
		).create_2d().get_node()

	died.emit()
	died_with_body.emit(_db)
	queue_free()
