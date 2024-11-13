extends Node2D

@export var goto_scene: String

@onready var music_loader = $MusicLoader
@onready var camera_2d = $Camera2D
@onready var nine_months_smooth = $NineMonthsSmooth
@onready var marker_2d = $Marker2D

const BOBAS_MARIO_1 = preload("res://stages/cutscenes/ending/part_3/sounds/bobas_mario_1.wav")
const BOBAS_MARIO_2 = preload("res://stages/cutscenes/ending/part_3/sounds/bobas_mario_2.wav")
const BOBAS_MARIO_3 = preload("res://stages/cutscenes/ending/part_3/sounds/bobas_mario_3.wav")
const BOBAS_MARIO_JUMP = preload("res://stages/cutscenes/ending/part_3/sounds/bobas_mario_jump.wav")

var _original_time_scale: float
var _skippable: bool
var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)

func _enter_tree() -> void:
	print('[Cutscene] altered time scale from %s' % Engine.time_scale)
	_original_time_scale = Engine.time_scale
	Engine.time_scale = 1

func _restore() -> void:
	print('[Cutscene] restored time scale %s' % _original_time_scale)
	Engine.time_scale = _original_time_scale

func _ready() -> void:
	_flow_intros()
	await get_tree().create_timer(1.2, false).timeout
	_skippable = true

func _flow_intros() -> void:
	await _time(5)
	
	var tw = create_tween()
	tw.tween_property(nine_months_smooth, "modulate:a", 1.0, 2)
	
	await _time(5)
	
	var tw2 = create_tween()
	tw2.tween_property(nine_months_smooth, "modulate:a", 0.0, 2)
	
	await _time(3)
	
	Audio.play_1d_sound(BOBAS_MARIO_1)
	await _time(2)
	Audio.play_1d_sound(BOBAS_MARIO_2)
	await _time(1)
	Audio.play_1d_sound(BOBAS_MARIO_3)
	
	await _time(1)
	_bobas_spawner()
	
	await _time(1)
	camera_2d.speed = -20
	
	await _time(10)
	_fade_out()

func _bobas_spawner() -> void:
	await _time(randf_range(0.1, 0.33))
	
	var bobas = preload("res://stages/cutscenes/ending/part_3/objects/bobas/bobas.tscn").instantiate()
	bobas.transform = marker_2d.transform
	Scenes.current_scene.add_child(bobas)
	
	_bobas_spawner()

func _time(t: float) -> void:
	await get_tree().create_timer(t, false).timeout

func _physics_process(_delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent):
	if !_skippable: return
	if event.is_action_pressed(&"pause_toggle"):
		_fade_out()

func _fade_out() -> void:
	_skippable = false
	
	_restore()
	await get_tree().physics_frame
	
	if !_crossfade:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
				.instantiate()
				.with_speeds(0.04, -0.1)
				.with_pause()
				.on_player_after_middle(false)
		)
		
		await TransitionManager.transition_middle
		Scenes.goto_scene(goto_scene)
	else:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
				.instantiate()
				.with_scene(goto_scene)
		)
