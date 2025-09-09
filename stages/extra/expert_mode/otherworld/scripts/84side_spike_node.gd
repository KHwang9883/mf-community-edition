extends Node

@onready var player_camera_2d: Camera2D = $"../../Path2D/PathFollow2D/PlayerCamera2D"
@onready var sprite_2d: Sprite2D = $"../Node2D/Sprite2D"
@onready var sprite_2d_2: Sprite2D = $"../Node2D2/Sprite2D2"
@onready var spike_ceiling: VBoxContainer = $"../../Parallax2D/SpikeCeiling"

var _first_done: bool
var _first_done_done: bool
var _idi_bistree: bool
var _idi_medlennee: bool
var _second_done: bool
var _second_done_done: bool
var _third_done: bool
var _final_disable_ceil: bool

var _ceiling_disabled: bool

func _physics_process(delta: float) -> void:
	if _ceiling_disabled:
		if is_instance_valid(spike_ceiling):
			spike_ceiling._state = 0
			if !_final_disable_ceil:
				spike_ceiling.global_position.y = spike_ceiling.init_pos.y
			spike_ceiling.timer.stop()
	
	if player_camera_2d.global_position.x > 2176 && !_first_done:
		_first_done = true
		_disable_ceiling()
		_activate_spikes()
	
	if player_camera_2d.global_position.x > 2688 && !_first_done_done:
		_first_done_done = true
		_enable_ceiling()
	
	if player_camera_2d.global_position.x > 3136 && !_idi_bistree:
		_idi_bistree = true
		_disable_ceiling()
		_activate_spikes_left()
	
	if player_camera_2d.global_position.x > 3520 && !_idi_medlennee:
		_idi_medlennee = true
		_activate_spikes_right()
	
	if player_camera_2d.global_position.x > 4352 && !_second_done:
		_second_done = true
		_activate_spikes()
	
	if player_camera_2d.global_position.x > 4672 && !_second_done_done:
		_second_done_done = true
		_enable_ceiling()
	
	if player_camera_2d.global_position.x > 5888 && !_third_done:
		_third_done = true
		sprite_2d_2._timeout = 15
		_activate_spikes_right()
		_disable_ceiling()
	
	if player_camera_2d.global_position.x > 6784 && !_final_disable_ceil:
		_final_disable_ceil = true
		_ceiling_nahui()
		_activate_spikes_left()

func _activate_spikes() -> void:
	sprite_2d._state = 1
	sprite_2d_2._state = 1

func _activate_spikes_left() -> void:
	sprite_2d._state = 1

func _activate_spikes_right() -> void:
	sprite_2d_2._state = 1

func _disable_ceiling() -> void:
	_ceiling_disabled = true

func _enable_ceiling() -> void:
	_ceiling_disabled = false
	spike_ceiling.timer.start(2.5)
	

func _ceiling_nahui() -> void:
	var tw = create_tween()
	tw.tween_property(spike_ceiling, "global_position:y", -416, 1)
	await tw.finished
	spike_ceiling.queue_free()
