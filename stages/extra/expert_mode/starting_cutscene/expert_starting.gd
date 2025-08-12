extends Node2D

@export var goto_scene: String = "res://stages/world_1/expert_map_1.tscn"

@onready var music_loader = $MusicLoader
@onready var camera_1: PathFollow2D = $Path2D/PathFollow2D
@onready var camera_2: PathFollow2D = $Path2D2/PathFollow2D
@onready var camera_3: Camera2D = $Camera2D2
@onready var color_rect: ColorRect = $CanvasLayer2/ColorRect

@onready var cutscene_2: Node2D = $Cutscene2
@onready var bowser: AnimatedSprite2D = $Cutscene2/Bowser
@onready var cpu_particles_2d: CPUParticles2D = $Cutscene2/CPUParticles2D
@onready var shrooms: Node2D = $Cutscene2/Shrooms
@onready var toad: AnimatedSprite2D = $Cutscene3/Toad
@onready var bonus: Sprite2D = $Cutscene3/Toad/Bonus
@onready var q_block: AnimatedSprite2D = $Cutscene3/QBlock
@onready var marker_q_block: Marker2D = $Cutscene3/MarkerQBlock
@onready var marker_toad: Marker2D = $Cutscene3/MarkerToad
@onready var marker_toad2: Marker2D = $Cutscene3/MarkerToad2

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
	for i in shrooms.get_children():
		i.scale = Vector2.ZERO
	bonus.modulate.a = 0
	toad.get_node("Arm").visible = false
	
	# TANKS
	var tw = create_tween()
	tw.tween_property(camera_1, "speed", 20, 2.0)
	#_test_timer = 0.001
	await _time(32)
	# OVERWORLD, BOWSER
	tw = create_tween()
	tw.tween_property(color_rect, "color:a", 1.0, 1.0)
	tw.tween_callback(func():
		camera_1.get_node("Camera2D").enabled = false
		camera_2.get_node("Camera2D").make_current()
		camera_2.speed = 25
		$ParallaxBackground.visible = false
		$Particle.hide()
	)
	tw.tween_property(color_rect, "color:a", 0.0, 1.0)
	await _time(20)
	bowser_animation()
	await _time(10)
	# UNDERGROUND, TOAD
	tw = create_tween()
	tw.tween_property(color_rect, "color:a", 1.0, 1.0)
	tw.tween_callback(func():
		camera_2.get_node("Camera2D").enabled = false
		#camera_3.enabled = true
		camera_3.make_current()
		$Node2D2/CanvasModulate2.visible = true
		$ParallaxBackground3.visible = true
		$ParallaxBackground2.visible = false
	)
	tw.tween_property(color_rect, "color:a", 0.0, 1.0)
	await _time(5)
	toad_animation()
	
	await _time(24.5)
	if !_skippable: return
	_fade_out()


func bowser_animation() -> void:
	bowser.play(&"hold")
	await _time(0.6)
	cpu_particles_2d.emitting = true
	await _time(3)
	cpu_particles_2d.gravity = Vector2(0, 200)
	await _time(1.5)
	for i in shrooms.get_children():
		var tw = i.create_tween()
		tw.tween_property(i, "scale", Vector2.ONE, 1.0)
		await _time(0.2)
	
	bowser.play(&"laugh")

func toad_animation() -> void:
	cpu_particles_2d.hide()
	bowser.hide()
	toad.play(&"walk")
	var tw = create_tween()
	tw.tween_property(toad, "position:x", marker_toad.position.x + 32, 3.0)
	tw.tween_callback(toad.play.bind(&"default"))
	tw.tween_interval(1.5)
	tw.tween_callback(func():
		toad.flip_h = true
	)
	tw.tween_interval(2.0)
	tw.tween_callback(func():
		toad.flip_h = false
	)
	tw.tween_interval(0.5)
	tw.tween_callback(toad.play.bind(&"walk"))
	tw.tween_property(toad, "position:x", marker_toad2.position.x, 0.4)
	tw.tween_callback(toad.play.bind(&"default"))
	tw.tween_interval(0.5)
	tw.tween_callback(toad.play.bind(&"kick"))
	tw.tween_callback(q_block.play.bind(&"opening"))
	tw.tween_interval(1.0)
	tw.tween_callback(toad.play.bind(&"loading"))
	tw.tween_property(bonus, "modulate:a", 1.0, 0.3)
	tw.chain().tween_property(bonus, "position:y", -28, 0.6)
	tw.tween_interval(1.5)
	tw.tween_callback(toad.play.bind(&"loading_jump"))
	tw.tween_property(toad, "position:y", toad.position.y - 48, 0.6) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func():
		var tw2 = bonus.create_tween()
		tw2.tween_property(bonus, "position:x", -31, 0.4)
		tw2.chain().tween_property(bonus, "position:y", 7, 0.6) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_delay(0.1)
		tw2.tween_callback(bonus.hide)
	)
	tw.tween_property(toad, "position:y", marker_toad.position.y, 0.6) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_callback(toad.play.bind(&"default"))
	tw.tween_interval(1.5)
	tw.tween_callback(toad.play.bind(&"walk"))
	tw.tween_property(toad, "position:x", marker_toad.position.x, 0.5)
	tw.tween_callback(toad.play.bind(&"prepare"))
	tw.tween_interval(0.4)
	tw.tween_callback(toad.play.bind(&"pickup"))
	tw.tween_interval(1.0)
	tw.tween_property(q_block, "position:y", 382, 0.6)
	tw.tween_callback(q_block.play.bind(&"closing"))
	q_block.animation_finished.connect(func():
		if q_block.animation != "closing": return
		q_block.offset.y = 12
		q_block.play(&"default")
		q_block.reset_physics_interpolation()
	)
	tw.tween_callback(toad.play.bind(&"hold"))
	tw.tween_callback(toad.get_node("Arm").show)
	tw.tween_interval(2.0)
	tw.tween_callback(func():
		var tw2 = toad.create_tween().set_trans(Tween.TRANS_SINE)
		tw2.tween_property(q_block, "position:y", q_block.position.y + 2, 0.3)
		tw2.tween_callback(toad.play.bind(&"throw"))
		tw2.tween_callback(toad.get_node("Arm").hide)
		tw2.tween_property(q_block, "position:y", marker_q_block.position.y - 12, 0.6) \
			.set_ease(Tween.EASE_OUT)
		tw2.tween_property(q_block, "position:y", marker_q_block.position.y, 0.15) \
			.set_ease(Tween.EASE_IN)
	)
	tw.tween_interval(2.0)
	tw.tween_callback(func():
		toad.flip_h = true
		toad.play(&"walk")
		toad.speed_scale = 1.2
	)
	tw.tween_property(toad, "position:x", 660, 3.5)
	
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
		_fade_out(true)

func _time(t: float) -> void:
	await get_tree().create_timer(t, false).timeout


func _fade_out(forced: bool = false) -> void:
	_skippable = false
	if !forced && _crossfade:
		await get_tree().create_timer(1.0, false, true, true).timeout
		Audio.stop_music_channel(1, true)
		
	_restore()
	await get_tree().physics_frame
	ProfileManager.current_profile.data.current_world = goto_scene
	ProfileManager.save_current_profile()
	
	if !_crossfade:
		Audio.stop_music_channel(1, true)
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
		Audio.stop_music_channel(1, false)
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
				.instantiate()
				.with_scene(goto_scene)
		)
