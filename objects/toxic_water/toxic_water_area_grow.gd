extends VBoxContainer

var grow: bool = false
var up_sound = preload("res://objects/toxic_water/lava_up.wav")
var _set: bool = false
var _ref_pos_y = 0
var _count: float = 0
var _change = false

func _physics_process(delta: float) -> void:
	if grow:
		_set = false
		_count = 180
		if global_position.y > -736:
			global_position.y -= 1.6 * Thunder.get_delta(delta)
		else:
			grow = false
		return
	
	if !grow:
		if !_set:
			_ref_pos_y = global_position.y
			_set = true
		_count += 100 * delta
		global_position.y = _ref_pos_y + sin(deg_to_rad(_count)) * 5
	
	if !is_instance_valid(Thunder._current_player): return
	
	if (
		Thunder._current_player.global_position.x > 6272 &&
		Thunder._current_player.global_position.x < 6848 &&
		Thunder._current_player.global_position.y < 256 &&
		Thunder._current_player.global_position.y > 64
	):
		grow = true
		Audio.play_1d_sound(up_sound)
	
	if Thunder._current_player.global_position.x > 7040 && !_change:
		_change = true
		global_position.y = -736
		_ref_pos_y = global_position.y
