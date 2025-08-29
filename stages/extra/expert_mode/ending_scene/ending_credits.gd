extends Node2D

@export var goto_path: String
@onready var color_rect: ColorRect = $Canvas/ColorRect
var _original_time_scale: float
var skippable: bool = false
var skippable_extra: bool = false
var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)
@onready var credits: Control = $Canvas/Credits
@onready var peach: AnimatedSprite2D = $Node2D/peach
@onready var thanks: RichTextLabel = $Canvas/thanks

var counter: float = -1.0

@onready var node_2d: Node2D = $Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	color_rect.visible = true
	credits.visible = false
	credits.modulate.a = 0.0
	
	var tw = color_rect.create_tween()
	tw.tween_property(color_rect, "color:a", 0.0, 3.0)
	animation_player.play(&"new_animation")
	await get_tree().create_timer(3.0, false).timeout
	skippable = true
	print("set skippable")

func _physics_process(delta: float) -> void:
	if counter < 0: return
	counter += delta * 20
	credits.position.y = -counter
	if credits.position.y < -2144:
		skippable_extra = true
	if credits.position.y <= -2900:
		counter = -99
	if thanks.position.y > 0:
		thanks.position.y = credits.position.y + 2432
	else:
		thanks.position.y = 0

func end_sequence() -> void:
	credits.visible = true
	var camera_2d = $Camera2D
	#animation_player.stop(true)
	var tw = create_tween()
	tw.tween_property(peach, "modulate:a", 0.0, 0.5)
	tw.tween_interval(1.0)
	tw.tween_property(camera_2d, "position:y", -720, 5.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tw.tween_property(credits, "modulate:a", 1.0, 2.0)
	tw.tween_interval(1.5)
	await tw.finished
	counter = 0

func _enter_tree() -> void:
	print('[Cutscene] altered time scale from %s' % Engine.time_scale)
	_original_time_scale = Engine.time_scale
	Engine.time_scale = 1

func _restore() -> void:
	print('[Cutscene] restored time scale %s' % _original_time_scale)
	Engine.time_scale = _original_time_scale

func _unhandled_input(event: InputEvent):
	if !skippable: return
	if event.is_action_pressed(&"ui_cancel"):
		_start_transition()
	if !skippable_extra: return
	
	if event.is_action_pressed(&"m_jump"):
		_start_transition()

func _start_transition() -> void:
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
		Scenes.goto_scene(goto_path)
	else:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
				.instantiate()
				.with_scene(goto_path)
		)
