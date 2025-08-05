extends Node2D

@export var goto_scene: String = "res://stages/world_1/expert_map_1.tscn"

@onready var music_loader = $MusicLoader
@onready var camera_1: PathFollow2D = $Path2D/PathFollow2D
@onready var camera_2: PathFollow2D = $Path2D2/PathFollow2D
@onready var color_rect: ColorRect = $CanvasLayer2/ColorRect

var _original_time_scale: float
var _skippable: bool
var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)
var _test_timer: float

func _ready() -> void:
	_flow_intros()
	await get_tree().create_timer(1.0, false, false, true).timeout
	_skippable = true

func _enter_tree() -> void:
	print('[Cutscene] altered time scale from %s' % Engine.time_scale)
	_original_time_scale = Engine.time_scale
	Engine.time_scale = 1

func _restore() -> void:
	print('[Cutscene] restored time scale %s' % _original_time_scale)
	Engine.time_scale = _original_time_scale

func _flow_intros() -> void:
	# INTRO
	
	music_loader.play_buffered()
	
	var tw = create_tween()
	tw.tween_property(camera_1, "speed", 20, 2.0)
	_test_timer = 0.001
	await _time(35)
	tw = create_tween()
	tw.tween_property(color_rect, "color:a", 1.0, 1.0)
	tw.tween_callback(func():
		camera_1.enabled = false
		camera_2.speed = 25
		$ParallaxBackground.visible = false
	)
	tw.tween_property(color_rect, "color:a", 0.0, 1.0)
	await _time(10)
	bowser_animation()
	await _time(15)
	
	await _time(80)
	if !_skippable: return
	_fade_out()


func bowser_animation() -> void:
	pass

func _physics_process(delta: float) -> void:
	if !_skippable: return
	if _test_timer > 0.0:
		_test_timer += delta
		if camera_1.progress_ratio >= 1.0:
			print(_test_timer)
			_test_timer = 0
	if (
		Input.is_action_pressed(&"m_attack") || Input.is_action_pressed(&"ui_accept") ||
		Input.is_action_pressed(&"m_extra") || Input.is_action_pressed(&"ui_select") ||
		Input.is_action_pressed(&"m_jump") || Input.is_action_pressed(&"m_run")
	):
		_fade_out()

func _time(t: float) -> void:
	await get_tree().create_timer(t, false).timeout


func _fade_out() -> void:
	_skippable = false
	
	_restore()
	Audio.stop_music_channel(1, true)
	await get_tree().physics_frame
	
	if !_crossfade:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
				.instantiate()
				.with_speeds(0.01, -0.1)
				.with_pause()
				#.on_player_after_middle(true)
		)
		
		await TransitionManager.transition_middle
		Scenes.goto_scene(goto_scene)
	else:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
				.instantiate()
				.with_scene(goto_scene)
		)
