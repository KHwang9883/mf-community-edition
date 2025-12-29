extends Node

const CASTLE_BRICK = preload("res://engine/scenes/castle_cutscene/objects/castle_brick.tscn")
const CASTLE_SMOKE = preload("res://engine/scenes/castle_cutscene/objects/castle_smoke.tscn")

const BREAK = preload("res://engine/objects/bumping_blocks/_sounds/break.wav")
const HURT = preload("res://engine/objects/bosses/bowser/sounds/bowser_hurt.wav")
const KICK = preload("res://engine/objects/players/prefabs/sounds/kick.wav")
const STUN = preload("res://engine/objects/projectiles/sounds/stun.wav")
const FALL = preload("uid://cr02ek5gpx3ly")

@onready var player: Player = Thunder._current_player
@onready var castle = $"../Castle"

@onready var castle_end_marker = $"../CastleEndMarker"
@onready var castle_pos: float = castle.position.x
#@onready var marker_2d = $"../Castle/Marker2D"
@onready var animated_sprite_2d: AnimatedSprite2D = $"../Node2D/AnimatedSprite2D"
var anims: Array

var _player_speed: float = 0.0
var _moving: bool = false
var _finished: float = 0.0

var _letit: bool = false
var _accel: float

signal player_at_wall

func _ready() -> void:
	await get_parent().ready
	player = Thunder._current_player
	player.completed = true
	await _time(1.5)
	var tw = create_tween()
	tw.tween_property(player, "modulate:a", 1.0, 1.0)
	await _time(0.5)
	_moving = true
	await player_at_wall
	
	await _time(1)
	var _sfx = CharacterManager.get_sound_replace(HURT, HURT, "bowser_hurt", false)
	Audio.play_1d_sound(_sfx)
	Thunder._current_camera.shock_smooth(2)
	await _time(0.8)
	_sfx = CharacterManager.get_sound_replace(KICK, KICK, "enemy_kick", false)
	Audio.play_1d_sound(_sfx)
	Thunder._current_camera.shock_smooth(4)
	await _time(0.4)
	_sfx = CharacterManager.get_sound_replace(BREAK, BREAK, "block_break", false)
	Audio.play_1d_sound(_sfx)
	Thunder._current_camera.shock_smooth(4)
	await _time(0.8)
	_sfx = CharacterManager.get_sound_replace(STUN, STUN, "stun", false)
	Audio.play_1d_sound(_sfx)
	Thunder._current_camera.shock_smooth(10)
	await _time(0.8)
	_sfx = CharacterManager.get_sound_replace(KICK, KICK, "enemy_kick", false)
	Audio.play_1d_sound(_sfx)
	Thunder._current_camera.shock_smooth(20)
	await _time(0.8)
	_sfx = CharacterManager.get_sound_replace(BREAK, BREAK, "block_break", false)
	Audio.play_1d_sound(_sfx)
	Thunder._current_camera.shock_smooth(20)
	await _time(0.4)
	_sfx = CharacterManager.get_sound_replace(KICK, KICK, "enemy_kick", false)
	Audio.play_1d_sound(_sfx)
	Thunder._current_camera.shock_smooth(30)
	await _time(0.2)
	_sfx = CharacterManager.get_sound_replace(STUN, STUN, "stun", false)
	Audio.play_1d_sound(_sfx)
	Thunder._current_camera.shock_smooth(30)
	for i in 3:
		await _time(0.2)
		_sfx = CharacterManager.get_sound_replace(BREAK, BREAK, "block_break", false)
		Audio.play_1d_sound(_sfx)
		Thunder._current_camera.shock_smooth(30)
	
	await _time(0.8)
	Audio.play_1d_sound(FALL)
	animated_sprite_2d.out = true
	for i in 30:
		var boo = animated_sprite_2d.duplicate()
		boo.speed.x = randf_range(400, 800)
		boo.speed.y = randf_range(-100, -350)
		boo.out = true
		animated_sprite_2d.add_sibling(boo)
	_letit = true
	_accel = -450
	await _time(4.5)
	_finished = 3


var more_offset: float
func _physics_process(delta: float) -> void:
	if _moving:
		player.speed.x = _player_speed
		_player_speed = move_toward(_player_speed, 325, delta * 250)
	
		if player.is_on_wall():
			player.left_right = 1
			player.modulate.a = 0.05
			player_at_wall.emit()
	
	if _letit:
		#castle_not_broken.offset.x = randf_range(-_offset.x, _offset.x) / 2.0
		_accel += delta * 350
		castle.position.y += _accel * delta
		castle.scale = castle.scale.move_toward(Vector2.ZERO, delta * 0.5)
		castle.modulate.a = move_toward(castle.modulate.a, 0.0, delta * 0.4)
		more_offset += 5 * delta
		castle.rotation_degrees -= delta * 25
		#castle.position.x -= more_offset * delta * 50
	
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
	#smoke.position = Vector2(marker_2d.global_position + Vector2(randi_range(-160, 160), 0)).rotated(castle.global_rotation)
	smoke.reset_physics_interpolation()
	smoke.y_modifier = randi_range(-40, -60)
	smoke.y_modify_over_time = 1
	smoke.apply_force_below_y = 400
	smoke.rotation_speed = randi_range(-180, 180)
	Scenes.current_scene.add_child(smoke)

func _time(sec: float) -> void:
	await get_tree().create_timer(sec, false).timeout
