extends Node2D

@onready var path_follow_2d: PathFollow2D = $"../Path2D/PathFollow2D"
@onready var label: Label = $"../HUD/Label"
@onready var label_2: Label = $"../HUD/Label2"
@onready var destruction: AudioStreamPlayer = $"../Destruction"
var bump
var _break

func _ready() -> void:
	# setup sounds
	bump = CharacterManager.get_sound_replace(BUMP, BUMP, "block_bump", false)
	_break = CharacterManager.get_sound_replace(BREAK, BREAK, "block_break", false)
	
	# initial start delay
	path_follow_2d.speed = 0
	var lvl: Level = Scenes.current_scene
	while is_instance_valid(lvl) && !lvl._is_stage_ready:
		await get_tree().physics_frame
		if !is_inside_tree(): return
	print("ready?")
	label.activate()
	destruction.play()
	await get_tree().create_timer(3.0, false, false, true).timeout
	counter = 0
	create_tween().tween_property(destruction, "volume_db", -3.5, 1.5)
	await get_tree().create_timer(2.3, false, false, true).timeout
	print("go")
	label_2.activate()
	path_follow_2d.speed = 100

const JUMP = preload("res://engine/objects/players/prefabs/sounds/jump.wav")
const EXPLOSION_TANK = preload("res://stages/cutscenes/ending/part_1/scripts/explosion_tank.tscn")
const KUFON = preload("res://stages/extra/expert_mode/ending_scene/breakage/kufon.tscn")
const DAMAGED_TILE = preload("res://stages/extra/expert_mode/ending_scene/breakage/damaged_tile.tscn")
const explosion_effect = preload("res://engine/objects/effects/explosion/explosion.tscn")
const STUN = preload("res://engine/objects/projectiles/sounds/stun.wav")
const BUMP = preload("res://engine/objects/bumping_blocks/_sounds/bump.wav")
const BREAK = preload("res://engine/objects/bumping_blocks/_sounds/break.wav")
const CRUSH2 = preload("res://sfx/IntroCastleCrush2.wav")
const ENDING_ANIM_3 = preload("res://sfx/ending_anim_3.ogg")

@onready var mario: Player = Thunder._current_player

@onready var fire_markers: Node2D = $FireMarkers
@onready var marker_konchik: Marker2D = $FireMarkers/MarkerKonch
#@onready var breakage: GravityBody2D = $"breakage/GravityBody2D"
@onready var brick_generators = $BrickGenerators
@onready var scripted_1: Node2D = $Scripted1
@onready var sprite_2d: Sprite2D = $Scripted1/Sprite2D
@onready var scripted_1_col: CollisionShape2D = $Scripted1/Area2D/CollisionShape2D

var step: int
var counter: float = -1

func _physics_process(delta: float) -> void:
	var camera_2d: PlayerCamera2D = Thunder._current_camera
	if !camera_2d: return
	
	match step:
		# first brick fall and break
		0 when path_follow_2d.progress > 640:
			step += 1
			camera_2d.shock_smooth(6, 10)
			Audio.play_sound(_break, scripted_1)
			Audio.play_1d_sound(STUN)
			sprite_2d.visible = false
			var tile = DAMAGED_TILE.instantiate()
			tile.position = sprite_2d.global_position
			tile.speed = Vector2(randf_range(-3, 3), -randf_range(3, 6))
			Scenes.current_scene.add_child(tile)
			tile.reset_physics_interpolation()
			var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).set_parallel()
			tw.tween_property(scripted_1, "position", Vector2(6608, 270), 1.5)
			tw.tween_property(scripted_1, "rotation_degrees", 30, 1.5)
			var tw2 = create_tween()
			tw2.tween_interval(1.2)
			tw2.tween_callback(scripted_1_col.set_deferred.bind("disabled", false))
			tw2.tween_interval(0.25)
			tw2.tween_callback(func():
				for i in 3:
					var tile2 = DAMAGED_TILE.instantiate()
					tile2.position = Vector2(6736, 352)
					tile2.speed = Vector2(randf_range(-3, 3), -randf_range(5, 8))
					Scenes.current_scene.add_child(tile2)
					tile2.reset_physics_interpolation()
				var expl = EXPLOSION_TANK.instantiate()
				expl.position = Vector2(6736, 336)
				Scenes.current_scene.add_child(expl)
				expl.reset_physics_interpolation()
				camera_2d.shock_smooth(4, 10)
			)
			tw2.tween_interval(0.15)
			tw2.tween_callback(scripted_1_col.set_deferred.bind("disabled", true))
		# final bowser tank explosion sequence
		1 when path_follow_2d.progress > 800:
			step += 1
			camera_2d.shock_smooth(10, 20)
			Audio.play_sound(bump, marker_konchik)
			Audio.play_sound(CRUSH2, marker_konchik)
			Audio.play_sound(_break, marker_konchik)
			var BEAM = preload("res://stages/extra/expert_mode/ending_scene/breakage/damaged_beam.tscn")
			for i in 5:
				var beam = BEAM.instantiate()
				Scenes.current_scene.add_child(beam)
				beam.position = camera_2d.get_screen_center_position() + Vector2(400, randf_range(-128, 128))
				beam.speed = -Vector2.ONE * randf_range(5, 10)
				beam.reset_physics_interpolation()
			var tw = create_tween().set_loops(10)
			tw.tween_callback(func():
				var kufon = KUFON.instantiate()
				Scenes.current_scene.add_child(kufon)
				kufon.position = camera_2d.get_screen_center_position() + Vector2(400, randf_range(-128, 128))
				kufon.vel_set(-Vector2(50, 50) * randf_range(5, 10))
				kufon.reset_physics_interpolation()
			)
			tw.tween_interval(0.13)
		# second brick fall and break, chains fall
		2 when path_follow_2d.progress > 2784:
			step += 1
			$AnimationPlayer.play(&"scripted2")
			Audio.play_1d_sound(CRUSH2, false)
			camera_2d.shock_smooth(4, 10)
		3 when path_follow_2d.progress > 3520:
			step += 1
			Audio.play_1d_sound(CRUSH2, false)
			camera_2d.shock_smooth(4, 10)
			
			
			#var expl = EXPLOSION_TANK.instantiate()
			#expl.position = sprite_2d.global_position
			#Scenes.current_scene.add_child(expl)
			
	
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
		
		#if !pipe_broken && path_follow_2d.progress > 1940:
			#pipe_broken = true
			#var _sfx = CharacterManager.get_sound_replace(STUN, STUN, "stun", false)
			#Audio.play_sound(_sfx, svo)
			#svo.gravity_scale = 0.5
			#svo.get_node("Sprite2D/cover").visible = false
			#await get_tree().physics_frame
			#svo.collided_floor.connect(func() -> void:
				#svo.get_node("AudioStreamPlayer2D").play()
				#var _expl = explosion_effect.instantiate()
				#_expl.position.y = 48
				#svo.add_child(_expl)
			#, CONNECT_ONE_SHOT)

@onready var chains: Node2D = $Scripted2/Chains

func scr2_chain_fall() -> void:
	var camera_2d: PlayerCamera2D = Thunder._current_camera

	Audio.play_1d_sound(_break)
	Audio.play_1d_sound(ENDING_ANIM_3, false)
	var children := chains.get_children()
	for i in chains.get_child_count():
		if i < 5:
			children[i].queue_free()
			var expl = EXPLOSION_TANK.instantiate()
			expl.position = Vector2(6736, 336)
			Scenes.current_scene.add_child(expl)
			expl.reset_physics_interpolation()
			if Thunder._current_camera:
				camera_2d.shock_smooth(4, 10)
			continue
		for _j in 4:
			await get_tree().physics_frame
		Audio.play_1d_sound(ENDING_ANIM_3, false, {volume = -5})
		children[i].activate()

func scr2_end() -> void:
	Audio.play_1d_sound(_break)
	for i in 4:
		var tile2 = DAMAGED_TILE.instantiate()
		tile2.position = Vector2(4640 - (i * 16), 400)
		tile2.speed = Vector2(randf_range(-3, 3), -randf_range(6, 9))
		Scenes.current_scene.add_child(tile2)
		tile2.reset_physics_interpolation()
