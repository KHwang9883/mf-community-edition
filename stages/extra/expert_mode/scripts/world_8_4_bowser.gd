extends "res://engine/objects/bosses/bowser/bowser.gd"

# Bowser's Jumping
#func _jumping(delta: float) -> void:
	#if !is_on_floor():
		#return
	#_jump_factor += delta
	#if _jump_factor < jumping_interval:
		#return
	#
	#_jump_factor = 0
	## Jumping
	#var chance: float = randf_range(0, 1)
	#if chance < jumping_chance:
		#vel_set_y(jumping_speed)

func jump(jumping_speed: float) -> void:
	speed.y = -jumping_speed
