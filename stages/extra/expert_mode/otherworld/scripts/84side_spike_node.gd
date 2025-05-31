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

func _physics_process(delta: float) -> void:
	if player_camera_2d.global_position.x > 2176 && !_first_done:
		_first_done = true
		_disable_ceiling()
		_activate_spikes()
	
	if player_camera_2d.global_position.x > 2688 && !_second_done_done:
		_second_done_done = true
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
		_disable_ceiling()
		_activate_spikes()
	
	if player_camera_2d.global_position.x > 4672 && !_second_done_done:
		_second_done_done = true
		_enable_ceiling()

func _activate_spikes() -> void:
	sprite_2d._state = 1
	sprite_2d_2._state = 1

func _activate_spikes_left() -> void:
	sprite_2d._state = 1

func _activate_spikes_right() -> void:
	sprite_2d_2._state = 1

func _disable_ceiling() -> void:
	spike_ceiling._state = 0
	spike_ceiling.global_position.y = spike_ceiling.init_pos.y
	spike_ceiling.process_mode = Node.PROCESS_MODE_DISABLED

func _enable_ceiling() -> void:
	spike_ceiling.process_mode = Node.PROCESS_MODE_INHERIT
