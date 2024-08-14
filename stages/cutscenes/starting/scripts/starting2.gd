extends Node2D

@export var goto_scene: String = "res://stages/world_1/map_1.tscn"

@onready var music_loader = $MusicLoader
@onready var camera_2d = $Camera2D
@onready var destruction = $Destruction
@onready var tanks = $Tanks
@onready var mario = $Mario

var _original_time_scale: float
var _skippable: bool
var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)

var set_looking: bool = false

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
	music_loader.play_buffered()
	
	await get_tree().create_timer(5.1, false).timeout
	
	var tw = create_tween()
	tw.tween_property(camera_2d, "speed", 230, 1)
	destruction.play()
	camera_2d.shock(100, Vector2(2, 2))
	set_looking = true
	
	await get_tree().create_timer(6.4, false).timeout
	
	tanks.speed = -100
	
	await get_tree().create_timer(0.4, false).timeout
	
	var tw2 = create_tween()
	tw2.tween_property(camera_2d, "speed", -40, 1)
	
	await get_tree().create_timer(38, false).timeout
	_fade_out()

func _physics_process(_delta: float) -> void:
	if tanks.global_position.x < 100:
		mario.direction = -1
		mario.speed.x = -180
		mario.sprite.speed_scale = 5

func _unhandled_input(event: InputEvent):
	if !_skippable: return
	if event is InputEventKey:
		_fade_out()

func _fade_out() -> void:
	_skippable = false
	
	_restore()
	await get_tree().physics_frame
	ProfileManager.current_profile.data.current_world = goto_scene
	ProfileManager.save_current_profile()
	
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
