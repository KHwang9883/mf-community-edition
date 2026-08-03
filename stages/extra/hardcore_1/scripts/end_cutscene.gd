extends Node

const CASTLE_BRICK = preload("res://engine/scenes/castle_cutscene/objects/castle_brick.tscn")
const CASTLE_SMOKE = preload("res://engine/scenes/castle_cutscene/objects/castle_smoke.tscn")

@onready var player: Player = Thunder._current_player
@onready var castle = $"../Castle"
@onready var castle_end_marker = $"../CastleEndMarker"
@onready var castle_pos: float = castle.position.x
@onready var spikes: Node2D = $"../Node2D2"
@onready var spikes_pos: Vector2 = spikes.position


var _player_speed: float = 0.0
var _moving: bool = false
var _destroying: bool = false
var _finished: float = 0.0

var _sine: float
var _sine_move: float = 0
var _state: int
var _falling_vel: float
var _sd: bool
var bottom_line_position: float = 330

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
	#Audio.play_1d_sound(preload("res://sfx/IntroCastleCrush2.wav"))
	var del: float
	for i in 30:
		await get_tree().create_timer(del if del > 0.05 else 0.02, false).timeout
		if i == 0: del = 1.0
		del -= 0.1
		Audio.play_1d_sound(preload("res://engine/objects/players/prefabs/sounds/kick.wav"))
		Thunder._current_camera.shock(0.05, Vector2(2, 2))
		_sine_move = 5.0
		if i >= 29:
			_sine_move = 0
			_state = 2
	
	#return
	
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
	if _sine_move > 0:
		_sine_move -= 1 * delta
		_sine += 50 * delta
		spikes.position.y = spikes_pos.y + sin(_sine) * (_sine / 70.0)
	elif _state == 0:
		spikes.position.y = spikes_pos.y
	
	if _state == 2:
		_falling_vel += 30 * delta
		spikes.position.y = move_toward(spikes.position.y, bottom_line_position, _falling_vel * 50 * delta)
		if castle.position.y < spikes.position.y - 32:
			castle.position.y = spikes.position.y - 32
			castle.offset = Vector2(randi_range(-5, 5), randi_range(-3, 5))
			if castle.position.y >= 128 && !_sd:
				Audio.play_1d_sound(preload("res://engine/objects/bumping_blocks/_sounds/break.wav"))
				_brick_particles(8, true)
				_sd = true
		if spikes.global_position.y == bottom_line_position:
			castle.visible = false
			_state = 3
			_falling_vel = 0
			_brick_particles(16)
			Thunder._current_camera.shock_smooth(10, 5)
			Audio.play_1d_sound(preload("res://engine/objects/enemies/spike_ceiling/sfx/fall.wav"))
			run_while(_smoke_particles, 0.02)
			await get_tree().create_timer(2.0, false).timeout
			_state = 4
	elif _state == 4:
		spikes.position.y = move_toward(spikes.position.y, spikes_pos.y, 100.0 * delta)
		_destroying = true
	
	if _moving:
		player.speed.x = _player_speed
		_player_speed = move_toward(_player_speed, 325, delta * 250)
	
		if player.is_on_wall():
			player.left_right = 1
	
	if _destroying:
		castle.position.y += delta * 50
	if castle.position.y > castle_end_marker.position.y:
		_finished += delta
	if _finished > 0.0 && _finished < 999:
		_finished = 1000
		Scenes.current_scene.end()


func run_while(callable: Callable, repeat_delay: float) -> void:
	#if _finished: return
	callable.call()
	await get_tree().create_timer(repeat_delay, false, false, true).timeout
	run_while(callable, repeat_delay)


func _brick_particles(number: int, _d: bool = false) -> void:
	for i in number:
		var brick = CASTLE_BRICK.instantiate()
		brick.position = castle.global_position + Vector2(randi_range(-80, 80) + 157, 128 + (randi_range(0, 64) if _d else 0)) 
		brick.reset_physics_interpolation()
		brick.speed = Vector2(randf_range(-6.0, 6.0), randi_range(-9, -6))
		brick.z_index = 5 if _d else 7
		brick._z_toggle = false
		Scenes.current_scene.add_child(brick)


func _smoke_particles() -> void:
	var smoke = CASTLE_SMOKE.instantiate()
	smoke.position = castle_end_marker.position + Vector2(randi_range(-157, 157), 16)
	smoke.y_modifier = randi_range(-10, 10)
	smoke.rotation_speed = randi_range(-90, 90)
	Scenes.current_scene.add_child(smoke)
