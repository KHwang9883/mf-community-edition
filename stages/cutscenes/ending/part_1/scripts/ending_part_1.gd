extends Node2D

@export_file("*.tscn", "*.scn") var goto_path: String

const JUMP = preload("res://engine/objects/players/prefabs/sounds/jump.wav")
const EXPLOSION_TANK = preload("res://stages/cutscenes/ending/part_1/scripts/explosion_tank.tscn")
const KUFON = preload("res://stages/cutscenes/ending/part_1/scripts/kufon.tscn")
const DAMAGED_TILE = preload("res://stages/cutscenes/ending/part_1/scripts/damaged_tile.tscn")

@onready var camera_2d: PlayerCamera2D = $Path2D/PathFollow2D/Camera2D
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var destruction: AudioStreamPlayer = $Destruction

@onready var mario_path: PathFollow2D = $Path2D2/PathFollow2D
@onready var mario: Sprite2D = $Path2D2/PathFollow2D/Mario
@onready var peach_path: PathFollow2D = $Path2D2/PathFollow2D2
@onready var peach: Sprite2D = $Path2D2/PathFollow2D2/Peach

@onready var fire_markers: Node2D = $FireMarkers
@onready var marker_konchik: Marker2D = $FireMarkers/MarkerKonch
@onready var svo: GravityBody2D = $"сво/GravityBody2D"
@onready var brick_generators = $BrickGenerators

var _original_time_scale: float
var has_skipped: bool = false

var counter: float = -1.0
var pipe_broken: bool = false

func _ready() -> void:
	_flow_intros()

func _enter_tree() -> void:
	print('[Cutscene] altered time scale from %s' % Engine.time_scale)
	_original_time_scale = Engine.time_scale
	Engine.time_scale = 1

func _restore() -> void:
	print('[Cutscene] restored time scale %s' % _original_time_scale)
	Engine.time_scale = _original_time_scale


func _physics_process(delta):
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
		for i in brick_generators.get_children():
			if !Thunder.view.is_getting_closer(i, 32):
				continue
			if randi_range(0, 15) == 1:
				var tile = DAMAGED_TILE.instantiate()
				Scenes.current_scene.add_child(tile)
				tile.position = i.global_position
				tile.speed = Vector2(randf_range(-3, 3), -randf_range(5, 8))
		
		if !pipe_broken && path_follow_2d.progress > 1940:
			pipe_broken = true
			Audio.play_sound(preload("res://engine/objects/projectiles/sounds/stun.wav"), svo)
			svo.gravity_scale = 0.5
			svo.get_node("Sprite2D/cover").visible = false
		
		if camera_2d.get_screen_center_position().x < -7000:
			counter = -1.0
			create_tween().tween_property(destruction, "volume_db", -40, 1.5)
			
		

func _flow_intros():
	await get_tree().create_timer(2.0, false).timeout
	camera_2d.shock(4, Vector2(2, 2))
	destruction.play()
	Audio.play_sound(JUMP, mario)
	create_tween().tween_property(peach, "self_modulate:a", 1.0, 0.15)
	peach_path.speed = 175
	
	await get_tree().create_timer(1.0, false).timeout
	Audio.play_sound(JUMP, mario)
	create_tween().tween_property(mario, "self_modulate:a", 1.0, 0.15)
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
	Audio.play_sound(preload("res://engine/objects/bumping_blocks/_sounds/bump.wav"), marker_konchik)
	Audio.play_sound(preload("res://sfx/IntroCastleCrush2.wav"), marker_konchik)
	Audio.play_sound(preload("res://engine/objects/bumping_blocks/_sounds/break.wav"), marker_konchik)
	var BEAM = preload("res://stages/cutscenes/ending/part_1/scripts/damaged_beam.tscn")
	for i in 5:
		var beam = BEAM.instantiate()
		Scenes.current_scene.add_child(beam)
		beam.position = camera_2d.get_screen_center_position() + Vector2(400, randf_range(-128, 128))
		beam.speed = -Vector2.ONE * randf_range(5, 10)
	var tw = create_tween().set_loops(10)
	tw.tween_callback(func():
		var kufon = KUFON.instantiate()
		Scenes.current_scene.add_child(kufon)
		kufon.position = camera_2d.get_screen_center_position() + Vector2(400, randf_range(-128, 128))
		kufon.vel_set(-Vector2(50, 50) * randf_range(5, 10))
	)
	tw.tween_interval(0.13)


func _start_transition() -> void:
	if has_skipped: return
	has_skipped = true
	TransitionManager.accept_transition(
		load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
			.instantiate()
			.with_speeds(0.02, -0.1)
	)
	
	var scene_path = goto_path
	TransitionManager.transition_middle.connect(func():
		_restore()
		TransitionManager.current_transition.paused = true
		Scenes.goto_scene(scene_path)
		Scenes.scene_changed.connect(func(_current_scene):
			TransitionManager.current_transition.paused = false
		, CONNECT_ONE_SHOT)
	, CONNECT_ONE_SHOT)
