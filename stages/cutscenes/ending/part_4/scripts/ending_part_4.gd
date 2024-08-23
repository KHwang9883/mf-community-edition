extends Node2D

@onready var goto_scene: String = ProjectSettings.get("application/thunder_settings/main_menu_path")

@onready var camera_2d = $Camera2D
@onready var toad: PathFollow2D = $Path2D/PathFollow2D
@onready var bowser_broken: Sprite2D = $BowserBroken
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var node_2d: Node2D = $CanvasLayer/Node2D
@onready var press_key: Sprite2D = $CanvasLayer/PressKey
@onready var buziol_credits: Sprite2D = $CanvasLayer/Node2D/BuziolCredits

const KICK = preload("res://engine/objects/players/prefabs/sounds/kick.wav")

var _original_time_scale: float
var _skippable: bool
var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)

var walked: bool = false
var credits_finished: bool = false

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
	color_rect.modulate.a = 0
	node_2d.modulate.a = 0
	camera_2d.speed = -20
	
	await _time(6.3)
	toad.speed = 100

func _flow_stare() -> void:
	toad.speed = 0
	toad.sprite.speed_scale = 0
	toad.sprite.frame = 2
	
	for i in 2:
		await _time(2)
		toad.sprite.flip_h = true
		await _time(2)
		toad.sprite.flip_h = false
	
	await _time(2)
	toad.sprite.animation = "thinking"
	toad.sprite.speed_scale = 1
	
	await _time(4)
	toad.sprite.animation = "default"
	toad.sprite.speed_scale = 0
	toad.sprite.frame = 2
	
	await _time(1)
	toad.sprite.animation = "pinaet"
	bowser_broken.shock(0.4, Vector2(2, 2))
	Audio.play_1d_sound(KICK)
	
	await _time(0.4)
	toad.sprite.animation = "default"
	toad.sprite.speed_scale = 0
	toad.sprite.frame = 2
	
	await _time(1)
	var tw = create_tween()
	tw.tween_property(color_rect, "modulate:a", 0.7, 2)
	
	await _time(2)
	var tw2 = create_tween()
	tw2.tween_property(node_2d, "modulate:a", 1, 2)
	
	await _time(5)
	node_2d.speed = 20

func _time(t: float) -> void:
	await get_tree().create_timer(t, false).timeout

func _physics_process(_delta: float) -> void:
	if toad.progress_ratio >= 1 && !walked:
		walked = true
		_flow_stare()
	
	if (buziol_credits.global_position.y + buziol_credits.texture.get_height()) < 0:
		var tw = create_tween()
		tw.tween_property(press_key, "modulate:a", 1, 1)

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
