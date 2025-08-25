extends Node

const BOBAS_MARIO_JUMP = preload("res://stages/cutscenes/ending/part_3/sounds/bobas_mario_jump.wav")

signal bobas

func activate() -> void:
	var pl = Thunder._current_player
	if !pl: return
	pl.death_wait_time = 7.0
	pl.death_jump_to_scene = "res://stages/save_game_room/save_game_room.tscn"
	pl.set_meta(&"ignore_loludied", true)
	Thunder._connect(pl.died, _on_death)


func _on_death() -> void:
	await get_tree().create_timer(6.0, true).timeout
	Audio.play_1d_sound(BOBAS_MARIO_JUMP, true)
	bobas.emit()
