extends Node

const CASTLE_SMOKE = preload("res://stages/world_6/scripts/castle_smoke_w6.tscn")

@onready var player: Player = Thunder._current_player
@onready var castle = $"../Castle"
@onready var castle_end_marker = $"../CastleEndMarker"
@onready var castle_pos: Vector2 = castle.position
@onready var plushy_sun: Sprite2D = $"../Node2D/PlushySun"
@onready var sunklass: Sprite2D = $"../Node2D/PlushySun/Sunklass"


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
	
	Audio.play_1d_sound(preload("res://sfx/Wciagator.wav"))
	run_while(_smoke_particles, 0.1)
	var amplitude = Vector2(3, 3)
	tw = create_tween().set_loops()
	tw.tween_callback(
		func() -> void:
			castle.offset = Vector2(
				randf_range(-amplitude.x, amplitude.x),
				randf_range(-amplitude.y, amplitude.y)
			)
	).set_delay(0.01)
	#Thunder._current_camera.shock(2, Vector2(4, 4))
	await get_tree().create_timer(3, false, false, true).timeout
	Audio.play_1d_sound(preload("res://sfx/Wciagator.wav"))
	Audio.play_1d_sound(preload("res://engine/objects/bosses/bowser/sounds/bowser_died.wav"))
	tw.stop()
	castle.offset = Vector2.ZERO
	tw = create_tween().set_trans(Tween.TRANS_SPRING)
	tw.tween_property(castle, "scale:x", 0.18, 0.8).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(2, false).timeout
	
	Audio.play_1d_sound(preload("res://engine/objects/players/prefabs/sounds/pipe_cutscene.wav"))
	plushy_sun.self_modulate.a = 0
	sunklass.visible = true
	tw = create_tween()
	tw.tween_property(castle, "position:y", 608.0, 2.5)
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


func _smoke_particles() -> void:
	var smoke = CASTLE_SMOKE.instantiate()
	Scenes.current_scene.add_child(smoke)
