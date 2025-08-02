extends Node

const EXPLOSION_NEAREST = preload("res://stages/extra/world_10_syzx/objects/explosion_nearest.tscn")

@onready var player: Player = Thunder._current_player
@onready var castle = $"../Castle"
@onready var castle_end_marker = $"../CastleEndMarker"
@onready var castle_pos: Vector2 = castle.position

#@onready var brick_checker: Area2D = $"../Area2D"
@onready var castle_small: Sprite2D = $"../CastleSmall"
@onready var thwomp: CharacterBody2D = $"../Thwomp"


var _player_speed: float = 0.0
var _moving: bool = false
var _destroying: bool = false
var _finished: float = 0.0
var _thwomp_smiled: bool
var _speeding: float

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
	thwomp.speed.y = 5
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
		thwomp.speed.y += 3 + _speeding * delta
		_speeding += delta
		print(thwomp.speed.y)
		if thwomp.position.y > -192 && thwomp.speed.y < 930:
			_destroying = false
			thwomp.speed.y = 0
			_speeding = 0
			await get_tree().create_timer(2.8, false, true, false).timeout
			thwomp.speed.y = 950
			_destroying = true
			Thunder._connect(thwomp.stun, func():
				thwomp._on_smile()
				_thwomp_smiled = true
			, CONNECT_ONE_SHOT)


func run_while(callable: Callable, repeat_delay: float) -> void:
	if _finished: return
	callable.call()
	await get_tree().create_timer(repeat_delay, false, false, true).timeout
	run_while(callable, repeat_delay)


#func _smoke_particles() -> void:
	#var smoke = CASTLE_SMOKE.instantiate()
	#Scenes.current_scene.add_child(smoke)


func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body)
	if !is_instance_valid(castle_small): return
	if body == thwomp:
		castle_small.queue_free()
		var expl = EXPLOSION_NEAREST.instantiate()
		expl.position = castle_small.position
		expl.scale = thwomp.scale
		Scenes.current_scene.add_child(expl)
