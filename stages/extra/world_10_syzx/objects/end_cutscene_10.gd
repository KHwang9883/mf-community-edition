extends Node

const CASTLE_BRICK = preload("res://stages/world_1/scripts/castle_brick.tscn")
const CASTLE_SMOKE = preload("res://stages/world_1/scripts/castle_smoke.tscn")
const EXPLOSION_NEAREST = preload("res://stages/extra/world_10_syzx/objects/explosion_nearest.tscn")

@onready var player: Player = Thunder._current_player
@onready var castle = $"../Castle"
@onready var castle_end_marker = $"../CastleEndMarker"
@onready var castle_pos: Vector2 = castle.position

@onready var brick37: StaticBumpingBlock = $"../Brick37"
@onready var castle_small: Sprite2D = $"../CastleSmall"
@onready var thwomp: CharacterBody2D = $"../Thwomp"


var _player_speed: float = 0.0
var _moving: bool = false
var _destroying: bool = false
var _finished: float = 0.0
var _thwomp_smiled: bool
var _speeding: float
var _small_castle_seq: bool

func _ready() -> void:
	await get_parent().ready
	player = Thunder._current_player
	player.completed = true
	await get_tree().create_timer(0.5, false).timeout
	var tw = create_tween()
	tw.tween_property(player, "modulate:a", 1.0, 1.0)
	await get_tree().create_timer(0.5, false).timeout
	_moving = true
	await get_tree().create_timer(3.5, false).timeout
	
	thwomp._step = 1
	thwomp.speed.y = 1
	_speeding = 1
	_destroying = true
	#Thunder._current_camera.shock(2, Vector2(4, 4))
	await get_tree().create_timer(3, false, false, true).timeout
	castle.offset = Vector2.ZERO
	
	await get_tree().create_timer(2, false).timeout
	#tw = create_tween()
	#tw.tween_property(castle, "position:y", 608.0, 2.5)
	#_destroying = true
	#run_while(
		#func():
			#Audio.play_1d_sound(preload("res://sfx/IntroCastleCrush.wav"), true, {volume = -6}),
		#0.099
	#)
	#run_while(func(): castle.position.x = castle_pos + randi_range(-3, 3), 0.01)
	#run_while(_brick_particles, 0.15)


func _physics_process(delta: float) -> void:
	if _moving:
		player.speed.x = _player_speed
		_player_speed = move_toward(_player_speed, 300, delta * 250)
	
		if player.is_on_wall():
			player.left_right = 1
	
	if _thwomp_smiled && thwomp.position.y < -172 && _finished < 999:
		_finished = 1000
		Scenes.current_scene.end()
	
	if _destroying:
		thwomp.speed.y += 2 + _speeding * delta
		_speeding += delta
		#print(thwomp.speed.y)
		if thwomp.position.y > -64 && !_small_castle_seq:
			_small_castle_seq = true
			brick37.bricks_break()
			castle_small.queue_free()
			
			var expl = EXPLOSION_NEAREST.instantiate()
			expl.position = castle_small.position
			expl.scale = thwomp.scale
			Scenes.current_scene.add_child(expl)
		if thwomp.position.y > 64 && castle.position.y < thwomp.position.y + 258 && thwomp.speed.y >= 0:
			castle.position.y = thwomp.position.y + 258
		if thwomp.position.y > -192 && thwomp.speed.y < 930:
			_destroying = false
			thwomp.speed.y = 0
			_speeding = 0
			await get_tree().create_timer(1.6, false, true, false).timeout
			thwomp.speed.y = 950
			_destroying = true
			Thunder._connect(thwomp.stun, func():
				_brick_particles()
				run_while(_smoke_particles, 0.02)
				thwomp._on_smile()
				_thwomp_smiled = true
			, CONNECT_ONE_SHOT)


func run_while(callable: Callable, repeat_delay: float) -> void:
	if _finished: return
	callable.call()
	await get_tree().create_timer(repeat_delay, false, false, true).timeout
	run_while(callable, repeat_delay)


func _brick_particles() -> void:
	var brick = CASTLE_BRICK.instantiate()
	brick.position = castle_end_marker.position + Vector2(randi_range(-145, 145), 0)
	brick.reset_physics_interpolation()
	brick.speed = Vector2(randf_range(-4.0, 4.0), randi_range(-11, -6))
	Scenes.current_scene.add_child(brick)
	for i in 10:
		var _br = brick.duplicate()
		_br.position = castle_end_marker.position + Vector2(randi_range(-145, 145), 0)
		_br.reset_physics_interpolation()
		_br.speed = Vector2(randf_range(-4.0, 4.0), randi_range(-11, -6))
		Scenes.current_scene.add_child(_br)


func _smoke_particles() -> void:
	var smoke = CASTLE_SMOKE.instantiate()
	smoke.position = castle_end_marker.position + Vector2(randi_range(-157, 157), 0)
	smoke.reset_physics_interpolation()
	smoke.y_modifier = randi_range(-10, 10)
	smoke.rotation_speed = randi_range(-90, 90)
	Scenes.current_scene.add_child(smoke)
