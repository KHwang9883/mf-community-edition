extends LevelCutscene

@export var goto_scene: String

@onready var camera_2d = $Camera2D
@onready var mario: Player = Thunder._current_player
@onready var cell_peach = $CellPeach

var _original_time_scale: float
#var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)

var set_looking: bool = false
var mario_walking: bool = false

var peach_enter: bool = false
var mario_enter: bool = false

var _50_switch: bool = false

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
	super()


func _flow_intros() -> void:
	await _time(3)
	cell_peach.speed.x = 50
	mario.speed.x = 50
	mario_walking = true
	
	await _time(10)
	camera_2d.speed = 100
	
	await _time(3)
	camera_2d.speed = 50
	camera_2d.global_position.x = floor(camera_2d.global_position.x)
	mario.global_position.x = floor(mario.global_position.x)
	cell_peach.global_position.x = floor(cell_peach.global_position.x)

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
	mario.warp = mario.Warp.IN
	@warning_ignore("int_as_enum_without_match", "int_as_enum_without_cast")
	mario.warp_dir = 99
	mario.sprite.set_animation(&"win")
	
	await _time(1)
	
	var tw = create_tween()
	tw.tween_property(mario, "modulate:a", 0.0, 0.5)
	await _time(1.5)
	
	_fade_out()

func _time(t: float) -> void:
	await get_tree().create_timer(t, false).timeout

func _physics_process(_delta: float) -> void:
	if mario_walking:
		mario.speed.x = 50
		(func():
			mario.global_position.x = cell_peach.global_position.x - 40
		).call_deferred()
	
	if cell_peach.global_position.x >= 1056 && !peach_enter:
		peach_enter = true
		_flow_enter_castle()
	
	if mario.global_position.x >= 1056 && !mario_enter:
		mario_enter = true
		_flow_mario_enter_castle()

func _unhandled_input(event: InputEvent):
	if !skippable: return
	if event.is_action_pressed(&"ui_cancel"):
		_fade_out()

func _fade_out() -> void:
	skippable = false
	
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
