extends Player

var lives: int = 1

signal damaged_to(lives: int)

func _ready() -> void:
	Thunder._current_player_state = null
	super()

func hurt(tags: Dictionary = {}) -> void:
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
