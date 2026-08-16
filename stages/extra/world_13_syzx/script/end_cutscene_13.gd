extends Node

const CASTLE_SMOKE = preload("res://engine/scenes/castle_cutscene/objects/castle_smoke.tscn")
const ZAMEK_LECI = preload("res://engine/scenes/castle_cutscene/sounds/castle_fly.wav")
const PIPE = preload("res://engine/objects/players/prefabs/sounds/pipe.wav")
const FALL = preload("res://sfx/comedy_cartoon_falling_tone.mp3")

@onready var player: Player = Thunder._current_player
@onready var castle = $"../Airship"
@onready var airship_fall = $"../ParallaxBackground/ParallaxLayer2/AirshipFall"

@onready var castle_end_marker = $"../AirshipEndMarker"
@onready var castle_pos: float = castle.position.x
@onready var marker_2d = $"../Airship/Marker2D"

var _moving: bool = false
var _player_speed: float = 0.0
var _finished: float = 0.0

var _letit: bool = false
var _offset: Vector2
var _falling: bool = false
var _airship_speed: Vector2 = Vector2(0.9, 0.4)
var _airship_scale: Vector2 = Vector2(1.0, 0.1)

signal player_at_wall

func _ready() -> void:
	await get_parent().ready
	player = Thunder._current_player
	player.completed = true
	await _time(1.0)
	_moving = true
	var _sfx = CharacterManager.get_sound_replace(PIPE, PIPE, "pipe", false)
	Audio.play_1d_sound(_sfx, false)
	
	await _time(3.0)
	Audio.play_1d_sound(ZAMEK_LECI, false)
	_letit = true
	run_while(_smoke_particles, 0.02)
	Thunder._current_camera.shock_smooth(4, 100)
	
	await _time(6.0)
	_falling = true
	Audio.play_1d_sound(FALL, false)
	await _time(10.0)
	_finished = 3


var more_offset: float
func _physics_process(delta: float) -> void:
	if _moving:
		player.speed.x = _player_speed
		_player_speed = move_toward(_player_speed, 300, delta * 250)
	
		if player.is_on_wall():
			player.left_right = 1
	
	if _letit:
		_offset.y += 1.5 * delta
		castle.position.y -= 40 * delta * _offset.y
		
	if _falling:
		airship_fall.position += _airship_speed * delta * 50
		_airship_speed.x += 0.05 * delta
		airship_fall.modulate.a = move_toward(airship_fall.modulate.a, 0.0, delta * 0.12)
		airship_fall.scale = airship_fall.scale.move_toward(Vector2.ZERO, delta * _airship_scale.y)
		airship_fall.rotation_degrees += delta * _airship_scale.x
		_airship_scale += Vector2.ONE * 0.0025 * delta
	
	if _finished > 2.0 && _finished < 999:
		_finished = 1000
		Scenes.current_scene.end()


func run_while(callable: Callable, repeat_delay: float) -> void:
	if _finished: return
	callable.call()
	await get_tree().create_timer(repeat_delay, false, false, true).timeout
	run_while(callable, repeat_delay)


func _smoke_particles() -> void:
	var smoke = CASTLE_SMOKE.instantiate()
	smoke.position = Vector2(marker_2d.global_position + Vector2(randi_range(-96, 96), 0)).rotated(castle.global_rotation)
	smoke.reset_physics_interpolation()
	smoke.y_modifier = randi_range(-40, -60)
	smoke.y_modify_over_time = 0.5
	smoke.apply_force_below_y = 400
	smoke.rotation_speed = randi_range(-180, 180)
	Scenes.current_scene.add_child(smoke)

func _time(sec: float) -> void:
	await get_tree().create_timer(sec, false, false).timeout
