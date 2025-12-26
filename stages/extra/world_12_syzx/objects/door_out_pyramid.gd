extends "res://engine/objects/warps/door/door_out.gd"

func _on_animation_finished() -> void:
	if !sprite: return
	if sprite.animation == &"open":
		sprite.z_index = 1
		sprite_bg.z_index = 1
		sprite.play(&"close")
	elif sprite.animation == &"close":
		player_exit.emit()
		sprite.z_index = 0
		sprite.play(&"default")
		
		sprite_bg.z_index = 0
		player.warp = Player.Warp.NONE
		player = null
		Thunder._current_hud.timer.paused = false
	
