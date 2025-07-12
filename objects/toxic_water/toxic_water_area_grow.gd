extends VBoxContainer

var grow: bool = false
var up_sound = preload("res://objects/toxic_water/lava_up.wav")


func _physics_process(delta: float) -> void:
	if grow:
		if global_position.y > -736:
			global_position.y -= 1.6 * Thunder.get_delta(delta)
		return
	if !is_instance_valid(Thunder._current_player): return
	
	if (
		Thunder._current_player.global_position.x > 6272 &&
		Thunder._current_player.global_position.x < 6848 &&
		Thunder._current_player.global_position.y < 256 &&
		Thunder._current_player.global_position.y > 64
	):
		grow = true
		Audio.play_1d_sound(up_sound)
