extends LevelCutscene

#@export_file("*.tscn", "*.scn") var goto_path: String

const JUMP = preload("res://engine/objects/players/prefabs/sounds/jump.wav")
const EXPLOSION_TANK = preload("res://stages/cutscenes/ending/part_1/scripts/explosion_tank.tscn")
const KUFON = preload("res://stages/cutscenes/ending/part_1/scripts/kufon.tscn")
const DAMAGED_TILE = preload("res://stages/cutscenes/ending/part_1/scripts/damaged_tile.tscn")
const explosion_effect = preload("res://engine/objects/effects/explosion/explosion.tscn")
const STUN = preload("res://engine/objects/projectiles/sounds/stun.wav")

@onready var camera_2d: PlayerCamera2D = $Path2D/PathFollow2D/Camera2D
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var destruction: AudioStreamPlayer = $Destruction

@onready var mario_path: PathFollow2D = $Path2D2/PathFollow2D
@onready var mario: Player = Thunder._current_player
@onready var peach_path: PathFollow2D = $Path2D2/PathFollow2D2
@onready var peach: Sprite2D = $Path2D2/PathFollow2D2/Peach

@onready var fire_markers: Node2D = $FireMarkers
@onready var marker_konchik: Marker2D = $FireMarkers/MarkerKonch
@onready var svo: GravityBody2D = $"breakage/GravityBody2D"
@onready var brick_generators = $BrickGenerators

var _original_time_scale: float
#var has_skipped: bool = false

var counter: float = -1.0
var pipe_broken: bool = false

var trans: bool = false

#var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)

func _ready() -> void:
	_flow_intros()
	mario.completed = true
	super()


func _enter_tree() -> void:
	print('[Cutscene] altered time scale from %s' % Engine.time_scale)
	_original_time_scale = Engine.time_scale
	Engine.time_scale = 1

func _restore() -> void:
	print('[Cutscene] restored time scale %s' % _original_time_scale)
	Engine.time_scale = _original_time_scale


func _physics_process(delta):
	if path_follow_2d.progress_ratio >= 1 && !trans:
		trans = true
		_start_transition()
	
	if counter == -1.0: return
	counter += delta
	if counter > 0.04:
		counter = 0
		for i in fire_markers.get_children():
			if !Thunder.view.is_getting_closer(i, 32):
				continue
			if randi_range(0, 5) == 1:
				var expl = EXPLOSION_TANK.instantiate()
				Scenes.current_scene.add_child(expl)
				expl.global_position = i.global_position + Vector2(
					randi_range(-128, 128),
					randi_range(-128, 128)
				)
				expl.reset_physics_interpolation()
		for i in brick_generators.get_children():
			if !Thunder.view.is_getting_closer(i, 32):
				continue
			if randi_range(0, 15) == 1:
				var tile = DAMAGED_TILE.instantiate()
				Scenes.current_scene.add_child(tile)
				tile.position = i.global_position
				tile.reset_physics_interpolation()
				tile.speed = Vector2(randf_range(-3, 3), -randf_range(5, 8))
		
		if !pipe_broken && path_follow_2d.progress > 1940:
			pipe_broken = true
			var _sfx = CharacterManager.get_sound_replace(STUN, STUN, "stun", false)
			Audio.play_sound(_sfx, svo)
			svo.gravity_scale = 0.5
			svo.get_node("Sprite2D/cover").visible = false
			await get_tree().physics_frame
			svo.collided_floor.connect(func() -> void:
				svo.get_node("AudioStreamPlayer2D").play()
				var _expl = explosion_effect.instantiate()
				_expl.position.y = 48
				svo.add_child(_expl)
			, CONNECT_ONE_SHOT)
		
		if camera_2d.get_screen_center_position().x < -7000:
			counter = -1.0
			create_tween().tween_property(destruction, "volume_db", -40, 1.5)
		

const BUMP = preload("res://engine/objects/bumping_blocks/_sounds/bump.wav")

func _flow_intros():
	await get_tree().create_timer(2.0, false).timeout
	camera_2d.shock(4, Vector2(2, 2))
	destruction.play()
	var _sfx = CharacterManager.get_sound_replace(JUMP, JUMP, "jump", true)
	Audio.play_sound(_sfx, mario)
	create_tween().tween_property(peach, "self_modulate:a", 1.0, 0.15)
	peach_path.speed = 175
	
	await get_tree().create_timer(1.0, false).timeout
	_sfx = CharacterManager.get_sound_replace(JUMP, JUMP, "jump", true)
	Audio.play_sound(_sfx, mario)
	create_tween().tween_property(mario, "modulate:a", 1.0, 0.15)
	mario_path.speed = 175
	
	await get_tree().create_timer(2.0, false).timeout
	camera_2d.shock(100, Vector2(4, 2))
	create_tween().tween_property(destruction, "volume_db", -2.0, 1.5)
	
	await get_tree().create_timer(1.0, false).timeout
	create_tween().tween_property(path_follow_2d, "speed", 100, 0.5)
	counter = 0
	
	await get_tree().create_timer(2.0, false).timeout
	create_tween().tween_property(path_follow_2d, "speed", 150, 1.0)
	
	await get_tree().create_timer(6.0, false).timeout
	_sfx = CharacterManager.get_sound_replace(BUMP, BUMP, "block_bump", false)
	Audio.play_sound(_sfx, marker_konchik)
	Audio.play_sound(preload("res://sfx/IntroCastleCrush2.wav"), marker_konchik)
	const BREAK = preload("res://engine/objects/bumping_blocks/_sounds/break.wav")
	_sfx = CharacterManager.get_sound_replace(BREAK, BREAK, "block_break", false)
	Audio.play_sound(_sfx, marker_konchik)
	var BEAM = preload("res://stages/cutscenes/ending/part_1/scripts/damaged_beam.tscn")
	for i in 5:
		var beam = BEAM.instantiate()
		Scenes.current_scene.add_child(beam)
		beam.position = camera_2d.get_screen_center_position() + Vector2(400, randf_range(-128, 128))
		beam.reset_physics_interpolation()
		beam.speed = -Vector2.ONE * randf_range(5, 10)
	var tw = create_tween().set_loops(10)
	tw.tween_callback(func():
		var kufon = KUFON.instantiate()
		Scenes.current_scene.add_child(kufon)
		kufon.position = camera_2d.get_screen_center_position() + Vector2(400, randf_range(-128, 128))
		kufon.reset_physics_interpolation()
		kufon.vel_set(-Vector2(50, 50) * randf_range(5, 10))
	)
	tw.tween_interval(0.13)


func _unhandled_input(event: InputEvent):
	if !skippable: return
	if event.is_action_pressed(&"ui_cancel"):
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
