extends Node

const CASTLE_BRICK = preload("res://stages/world_1/scripts/castle_brick.tscn")
const CASTLE_SMOKE = preload("res://stages/world_1/scripts/castle_smoke.tscn")

const WIND = preload("res://sfx/wind.ogg")
const FLY = preload("res://sfx/fly.wav")

@onready var parallax_layer: ParallaxLayer = $"../ParallaxBackground2/ParallaxLayer"
@onready var wind_eff = $"../ParallaxBackground2/ParallaxLayer/WindEff"
@onready var player: Player = Thunder._current_player
@onready var castle = $"../Castle"
@onready var plushy_sun = $"../ParallaxBackground2/PlushySun"

@onready var audio_stream_player = $"../AudioStreamPlayer"

@onready var castle_end_marker = $"../CastleEndMarker"
@onready var castle_pos: float = castle.position.x

@onready var init_pos = castle.global_position + Vector2.ZERO

var _player_speed: float = 0.0
var _moving: bool = false
var _destroying: bool = false
var _finished: float = 0.0

var _shaking: bool = false
var _spidding: bool = false
var _spid: float = 0

var _flying: bool = false
var _sun_fly: bool = false

func _ready() -> void:
	await get_parent().ready
	player = Thunder._current_player
	player.completed = true
	await get_tree().create_timer(0.5, false).timeout
	var tw = create_tween()
	tw.tween_property(player, "modulate:a", 1.0, 1.0)
	await get_tree().create_timer(0.5, false).timeout
	_moving = true
	await get_tree().create_timer(2.5, false).timeout
	
	_spidding = true
	audio_stream_player.play()
	
	var tww = create_tween()
	tww.tween_property(wind_eff, "modulate:a", 0.5, 1)
	
	await get_tree().create_timer(2.5, false).timeout
	
	_shaking = true
	
	await get_tree().create_timer(1.5, false).timeout
	
	Audio.play_1d_sound(FLY)
	_shaking = false
	_flying = true
	
	await get_tree().create_timer(1, false).timeout
	
	_sun_fly = true
	
	await get_tree().create_timer(2, false).timeout
	
	audio_stream_player.stop()
	Scenes.current_scene.end()
	
	#Audio.play_1d_sound(preload("res://sfx/IntroCastleCrush2.wav"))
	#Thunder._current_camera.shock(2, Vector2(4, 4))
	#await get_tree().create_timer(2, false).timeout
	#_destroying = true
	#run_while(
		#func():
			#Audio.play_1d_sound(preload("res://sfx/IntroCastleCrush.wav"), true, {volume = -6}),
		#0.099
	#)
	#run_while(func(): castle.position.x = castle_pos + randi_range(-3, 3), 0.01)
	#run_while(_brick_particles, 0.15)
	#run_while(_smoke_particles, 0.02)


func _physics_process(delta: float) -> void:
	if _moving:
		player.speed.x = _player_speed
		_player_speed = move_toward(_player_speed, 325, delta * 250)
	
		if player.is_on_wall():
			player.left_right = 1
	
	if _destroying:
		castle.position.y += delta * 50
	if castle.position.y > castle_end_marker.position.y:
		_finished += delta
	if _finished > 2.0 && _finished < 999:
		_finished = 1000
		Scenes.current_scene.end()
	
	parallax_layer.motion_offset.x -= (300 + _spid) * delta
	if _spidding:
		_spid += 300 * delta
	
	if _shaking:
		castle.global_position = init_pos + Vector2(randi_range(-2, 2), randi_range(0, 2))
	
	if _flying:
		castle.global_position.x -= 600 * delta
		castle.global_position.y -= 100 * delta
		castle.rotation_degrees -= 100 * delta
	
	if _sun_fly:
		plushy_sun.global_position.x -= 600 * delta
		plushy_sun.rotation_degrees -= 300 * delta


func run_while(callable: Callable, repeat_delay: float) -> void:
	if _finished: return
	callable.call()
	await get_tree().create_timer(repeat_delay, false, false, true).timeout
	run_while(callable, repeat_delay)


func _brick_particles() -> void:
	var brick = CASTLE_BRICK.instantiate()
	brick.position = castle_end_marker.position + Vector2(randi_range(-145, 145), 16)
	brick.speed = Vector2(randf_range(-4.0, 4.0), randi_range(-11, -6))
	Scenes.current_scene.add_child(brick)


func _smoke_particles() -> void:
	var smoke = CASTLE_SMOKE.instantiate()
	smoke.position = castle_end_marker.position + Vector2(randi_range(-157, 157), 16)
	smoke.y_modifier = randi_range(-10, 10)
	smoke.rotation_speed = randi_range(-90, 90)
	Scenes.current_scene.add_child(smoke)
