extends "res://objects/final_boss_cell/final_boss_cell.gd"

var hud_scrolling: bool

@onready var control: Control = $"../Credits/Control"
var credits_index: int

func restore_camera() -> void:
	var cam: Camera2D = Thunder._current_camera
	if !cam: return
	cam.reparent(Scenes.current_scene)
	Thunder.reorder_on_top_of(cam, Thunder._current_player)
	cam.par = cam.get_parent()
	cam.force_update_transform()
	cam.reset_physics_interpolation()
	cam.force_update_scroll()

func _physics_process(delta: float) -> void:
	if !is_instance_valid(mario): return
	
	if _run_away:
		_player_speed = move_toward(_player_speed, 275, delta * 250)
		cell_peach.speed.x = move_toward(cell_peach.speed.x, 275, delta * 250)
		mario.speed.x = _player_speed
		mario.position.x += _player_speed * delta
		if hud_scrolling:
			var hud = Thunder._current_hud
			hud.get_node("Control").position.x -= _player_speed * delta
			hud.get_node("World").position.x -= _player_speed * delta
	
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
		mario.speed.x = 0
		_moving = false
		restore_camera()
		await get_tree().create_timer(0.2, false).timeout
		mario.direction = 1
		await get_tree().create_timer(0.5, false).timeout
		Audio.play_sound(JUMP, mario)
		Audio.play_sound(BREAK, mario)
		
		_particles()
		cell.visible = false
		mario.jump(-800)
		
		await get_tree().create_timer(0.4, false).timeout
		cell_peach.z_index = 5
		cell_peach.position.y = -44
		var spikes = Scenes.current_scene.get_node("SpikesSideRight")
		var tw = spikes.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tw.tween_property(spikes, "position:y", -400, 1.0)
		
		await get_tree().create_timer(0.4, false).timeout
		
		_run_away = true
		mario.no_movement = true
		cell_peach.play('walk')
		
		#await get_tree().create_timer(2, false).timeout
		
		#Scenes.current_scene.throw_to_scene()
	
	mario.speed.x = _player_speed


func hud_scroll() -> void:
	var hud = Thunder._current_hud
	hud.get_node("Control").physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	for i in hud.get_node("Control").get_children():
		if i is Node: i.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	for i in hud.get_node("Control/Control").get_children():
		if i is Node: i.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	hud_scrolling = true
	await get_tree().create_timer(4.0, false).timeout
	hud_scrolling = false


func parallax_switch() -> void:
	mario.position.y += 960
	mario.reset_physics_interpolation()
	cell_peach.position.y += 960
	cell_peach.reset_physics_interpolation()
	var cam = Thunder._current_camera
	cam.position.y += 960
	cam.reset_physics_interpolation()
	var cam_area: Control = $"../CamArea"
	var cam_area_2: Control = $"../CamArea2"
	cam_area.is_current = false
	cam_area_2._switch_bounds()
	cam.teleport()
	cam.force_update_transform()
	cam.reset_physics_interpolation()
	cam.force_update_scroll()
	var tw = create_tween()
	tw.tween_property(cam, "offset:y", -64, 1.5)
	tw.tween_callback(credits_start)

func credits_start() -> void:
	for i in control.get_child_count() + 1:
		create_tween().tween_property(control, "position:x", control.position.x - 640, 2.327273)
		await get_tree().create_timer(5.0 if i == 0 else 8.0, false, false, true).timeout
		if i == control.get_child_count():
			credit_end()
	
func credit_end() -> void:
	print('ended')
