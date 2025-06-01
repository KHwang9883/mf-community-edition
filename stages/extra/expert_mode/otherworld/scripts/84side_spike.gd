extends Sprite2D

const FALL = preload("res://engine/objects/enemies/spike_ceiling/sfx/fall.wav")
const SIDE_SPIKES = preload("res://stages/extra/expert_mode/otherworld/sounds/side_spikes.wav")

@export var draw_area_rect: bool
@export_group("Spike Ceiling Behaviour")
@export var activation_time: float = 4.0
@export var bottom_line_position: float = 408.0
@export var falling_speed: float = 1.0
@export var reabilitation_delay: float = 2.0
@export var reabilitation_speed: float = 100.0

var _timeout: float = 5.0

var _state: int = 0
var _sine: float
var _falling_vel: float
var _sound_played: bool

@onready var init_pos: Vector2 = position

func _physics_process(delta: float) -> void:
	var player: Player = Thunder._current_player
	
	if _state == 1:
		if !_sound_played:
			Audio.play_1d_sound(SIDE_SPIKES)
			_sound_played = true
		
		_sine += 50 * delta
		position.x = sin(_sine) * (_sine / 70.0)
		
		if _sine > 100:
			_state += 1
			position.x = 0
			_sine = 0
	elif _state == 2:
		_falling_vel += falling_speed * 50 * delta
		position.x = move_toward(position.x, bottom_line_position, _falling_vel * 50 * delta)
		if position.x == bottom_line_position:
			_state = 3
			_falling_vel = 0
			Thunder._current_camera.shock_smooth(10, 5)
			Audio.play_1d_sound(FALL)
			await get_tree().create_timer(_timeout, false).timeout
			_state = 4
	elif _state == 4:
		_sound_played = false
		_falling_vel += falling_speed * 50 * delta
		position.x = move_toward(position.x, 0, _falling_vel * 50 * delta)
		if position.x == 0:
			Thunder._current_camera.shock_smooth(10, 5)
			Audio.play_1d_sound(FALL)
			_falling_vel = 0
			_state = 0
