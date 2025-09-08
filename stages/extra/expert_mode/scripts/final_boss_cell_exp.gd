extends "res://objects/final_boss_cell/final_boss_cell.gd"

const DAMAGED_TILE = preload("res://stages/extra/expert_mode/ending_scene/breakage/damaged_tile.tscn")
const INTRO_CASTLE_CRUSH_2 = preload("res://sfx/IntroCastleCrush2.wav")
@onready var thwomp: CharacterBody2D = $"../Thwomp"
@onready var thwomp2: CharacterBody2D = $"../Thwomp2"

func _ready() -> void:
	await get_tree().create_timer(2, false).timeout
	
	_creation_mushroom()

func cutscene() -> void:
	if !is_instance_valid(mario):
		printerr('SHIT HAPPENED IN CUTSCENE!')
		return
	
	mario.completed = true
	
	await get_tree().create_timer(1, false).timeout
	if !is_instance_valid(mario):
		return
	
	animation_player.pause()
	_fade_help()
	
	if mario.global_position.x > marker_mario_destroyer_pos.global_position.x:
		mario.direction = -1
	elif mario.global_position.x < marker_mario_destroyer_pos.global_position.x:
		mario.direction = 1
	
	if is_instance_valid(thwomp) && thwomp.position.y > 16:
		var _tw = thwomp.create_tween().tween_property(thwomp, "position:y", -48, 2.0)
	if is_instance_valid(thwomp2) && thwomp2.position.y > 16:
		var _tw = thwomp2.create_tween().tween_property(thwomp2, "position:y", -48, 2.0)
	
	var tw = create_tween().set_parallel()
	tw.tween_property(self, "global_position:y", 364, 3.0)
	tw.tween_property(self, "modulate", Color.WHITE, 2.4)
	await tw.finished
	
	#await get_tree().create_timer(0.5, false).timeout
	
	_moving = true


func _physics_process(delta: float) -> void:
	if !is_instance_valid(mario): return
	
	if _run_away:
		_player_speed = move_toward(_player_speed, -325, delta * 250)
		cell_peach.speed.x = move_toward(cell_peach.speed.x, -325, delta * 250)
		mario.speed.x = _player_speed
		mario.direction = -1
	
	if !_moving: return
	
	# please kill me (c) reflex
	if mario.global_position.x > marker_mario_destroyer_pos.global_position.x + 156:
		_player_speed = move_toward(_player_speed, -325, delta * 250)
		mario.direction = -1
	elif mario.global_position.x < marker_mario_destroyer_pos.global_position.x - 156:
		_player_speed = move_toward(_player_speed, 325, delta * 250)
		mario.direction = 1
	elif mario.global_position.x > marker_mario_destroyer_pos.global_position.x + 16:
		_player_speed = move_toward(_player_speed, -125, delta * 250)
		mario.direction = -1
	elif mario.global_position.x < marker_mario_destroyer_pos.global_position.x - 16:
		_player_speed = move_toward(_player_speed, 125, delta * 250)
		mario.direction = 1
	else:
		_player_speed = 0
		_moving = false
		await get_tree().create_timer(0.2, false).timeout
		if !is_instance_valid(mario): return
		mario.direction = 1
		await get_tree().create_timer(0.5, false).timeout
		if !is_instance_valid(mario): return
		var _sfx = CharacterManager.get_sound_replace(JUMP, JUMP, "jump", true)
		Audio.play_sound(_sfx, mario)
		Audio.play_sound(BREAK, mario)
		
		_particles()
		cell.visible = false
		mario.jump(-800)
		
		await get_tree().create_timer(0.4, false).timeout
		cell_peach.z_index = 5
		await get_tree().create_timer(0.4, false).timeout
		
		_falling_tiles()
		Audio.play_1d_sound(INTRO_CASTLE_CRUSH_2, true, {ignore_pause = true})
		Thunder._current_camera.shock_smooth(8, 25)
		cell_peach.play('walk')
		cell_peach.speed_scale = 0
		cell_peach.flip_h = true
		
		await get_tree().create_timer(0.3, false).timeout
		cell_peach.flip_h = false
		await get_tree().create_timer(0.3, false).timeout
		cell_peach.flip_h = true
		await get_tree().create_timer(0.3, false).timeout
		cell_peach.flip_h = false
		if !is_instance_valid(mario): return
		mario.direction = -1
		
		await get_tree().create_timer(0.3, false).timeout
		
		_run_away = true
		cell_peach.play('walk')
		cell_peach.speed_scale = 1
		cell_peach.flip_h = true
		
		await get_tree().create_timer(2, false).timeout
		
		Scenes.current_scene.throw_to_scene()
	
	if !is_instance_valid(mario): return
	mario.speed.x = _player_speed

func _falling_tiles() -> void:
	while is_inside_tree():
		var tile = DAMAGED_TILE.instantiate()
		Scenes.current_scene.add_child(tile)
		tile.position = Vector2(randf_range(0, 640), -8)
		tile.speed = Vector2(randf_range(-1, 1), 3)
		tile.reset_physics_interpolation()
		await get_tree().create_timer(0.05, false).timeout
		if !is_instance_valid(Scenes.current_scene) || Scenes.current_scene.is_queued_for_deletion():
			break
	
