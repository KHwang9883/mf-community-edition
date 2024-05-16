extends Player

@onready var minix: Node = $"../Node"

func hurt(tags: Dictionary = {}) -> void:
	if !suit:
		return
	if !tags.get(&"hurt_forced", false) && (is_invincible() || completed || warp > Warp.NONE):
		return
	if warp != Warp.NONE: return
	
	if minix.lives > 0:
		minix.lives -= 1
		#change_suit(suit.gets_hurt_to)
		invincible(tags.get(&"hurt_duration", 2))
		Audio.play_sound(suit.sound_hurt, self, false, {pitch = suit.sound_pitch})
	else:
		die(tags)
	
	damaged.emit()
