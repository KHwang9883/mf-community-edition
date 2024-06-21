extends Node

const CASTLE_BRICK = preload("res://stages/world_1/scripts/castle_brick.tscn")
const CASTLE_SMOKE = preload("res://stages/world_1/scripts/castle_smoke.tscn")

@onready var player: Player = Thunder._current_player
@onready var castle = $"../Castle"
@onready var castle_end_marker = $"../CastleEndMarker"
@onready var castle_pos: float = castle.position.x


var _player_speed: float = 0.0
var _moving: bool = false
var _destroying: bool = false
var _finished: float = 0.0

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
	Audio.play_1d_sound(preload("res://sfx/IntroCastleCrush2.wav"))
	Thunder._current_camera.shock(2, Vector2(4, 4))
	await get_tree().create_timer(2, false).timeout
	_destroying = true
	run_while(func(): Audio.play_1d_sound(preload("res://sfx/IntroCastleCrush.wav")), 0.115)
	run_while(func(): castle.position.x = castle_pos + randi_range(-3, 3), 0.01)
	run_while(_brick_particles, 0.15)
	run_while(_smoke_particles, 0.02)


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


func run_while(callable: Callable, repeat_delay: float) -> void:
	if _finished: return
	callable.call()
	await get_tree().create_timer(repeat_delay, false, false, true).timeout
	run_while(callable, repeat_delay)


func _brick_particles() -> void:
	var brick = CASTLE_BRICK.instantiate()
	brick.position = castle_end_marker.position + Vector2(randi_range(-145, 145), 0)
	brick.speed = Vector2(randf_range(-4.0, 4.0), randi_range(-9, -5))
	Scenes.current_scene.add_child(brick)


func _smoke_particles() -> void:
	var smoke = CASTLE_SMOKE.instantiate()
	smoke.position = castle_end_marker.position + Vector2(randi_range(-157, 157), 0)
	Scenes.current_scene.add_child(smoke)
