extends Node

func _ready() -> void:
	await get_tree().physics_frame
	var pl: Player = $".."
	if Data.values.lives == 0 && pl.death_check_for_lives:
		pl.death_music_override = null
		pl.death_stop_music = true
		pl.death_wait_time = 3.5
