extends Node2D

@export var goto_scene: String

@onready var music_loader = $MusicLoader
@onready var camera_2d = $Camera2D
@onready var mario = $Mario
@onready var cell_peach = $CellPeach
@onready var win_pose = $WinPose

var _original_time_scale: float
var _skippable: bool
var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)

var set_looking: bool = false
var mario_walking: bool = false

var peach_enter: bool = false
var mario_enter: bool = false

func _enter_tree() -> void:
	print('[Cutscene] altered time scale from %s' % Engine.time_scale)
	_original_time_scale = Engine.time_scale
	Engine.time_scale = 1

func _restore() -> void:
	print('[Cutscene] restored time scale %s' % _original_time_scale)
	Engine.time_scale = _original_time_scale

func _ready() -> void:
	_flow_intros()
	mario.completed = true
	await get_tree().create_timer(1.2, false).timeout
	_skippable = true

func _flow_intros() -> void:
	await _time(3)
	cell_peach.speed.x = 50
	mario.speed.x = 50
	mario_walking = true
	
	await _time(10)
	camera_2d.speed = 100
	
	await _time(3)
	camera_2d.speed = 50

func _flow_enter_castle() -> void:
	camera_2d.speed = 0
	cell_peach.speed.x = 0
	cell_peach.speed_scale = 0
	mario.speed.x = 0
	mario_walking = false
	
	var tw = create_tween()
	tw.tween_property(cell_peach, "modulate:a", 0.0, 0.5)
	await tw.finished
	
	cell_peach.speed.x = 50
	mario.speed.x = 50
	mario_walking = true
	
	var tw2 = create_tween()
	tw2.tween_property(camera_2d, "global_position:x", 1056, 0.85)

func _flow_mario_enter_castle() -> void:
	camera_2d.speed = 0
	cell_peach.speed.x = 0
	cell_peach.speed_scale = 0
	mario.speed.x = 0
	mario_walking = false
	mario.visible = false
	
	match mario.suit.name:
		"small":
			win_pose.frame = 0
		"super":
			win_pose.frame = 1
		"fireball":
			win_pose.frame = 2
		"beetroot":
			win_pose.frame = 3
		"green_lui":
			win_pose.frame = 4
	
	var tex: Texture2D = win_pose.sprite_frames.get_frame_texture("default", win_pose.frame)
	win_pose.global_position.x -= tex.get_width() / 2
	win_pose.global_position.y -= tex.get_height()
	win_pose.visible = true
	
	await _time(1)
	
	var tw = create_tween()
	tw.tween_property(win_pose, "modulate:a", 0.0, 0.5)
	await _time(1.5)
	
	_fade_out()

func _time(t: float) -> void:
	await get_tree().create_timer(t, false).timeout

func _physics_process(_delta: float) -> void:
	if mario_walking:
		mario.speed.x = 50
		mario.global_position.x = cell_peach.global_position.x - 40
	
	if cell_peach.global_position.x >= 1056 && !peach_enter:
		peach_enter = true
		_flow_enter_castle()
	
	if mario.global_position.x >= 1056 && !mario_enter:
		mario_enter = true
		_flow_mario_enter_castle()

func _unhandled_input(event: InputEvent):
	if !_skippable: return
	if event is InputEventKey:
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
				.on_player_after_middle(true)
		)
		
		await TransitionManager.transition_middle
		Scenes.goto_scene(goto_scene)
	else:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
				.instantiate()
				.with_scene(goto_scene)
		)
