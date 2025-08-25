extends "res://objects/final_boss_cell/final_boss_cell.gd"

var hud_scrolling: bool

@onready var control: Control = $"../Credits/Control"
@onready var parallax_2d: Parallax2D = $"../Parallax2D"
@onready var ending: Node2D = $"../Ending"
@onready var ending_marker: Marker2D = $"../Ending/Marker2D"
@onready var any_key: CanvasLayer = $"../AnyKey"
@onready var any_key_label: Label = $"../AnyKey/Label"
@onready var static_body_2d: StaticBody2D = $"../StaticBody2D"

var tp_peach: bool = false
var slowing_down: bool = false
var end_modulating: bool = false
var skippable: bool = false
var _original_time_scale: float

func _ready() -> void:
	super()
	any_key.visible = false

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
	
	if skippable:
		if Input.is_action_just_pressed(&"m_jump"):
			skippable = false
			Scenes.current_scene.throw_to_scene()
		return
	
	if end_modulating:
		static_body_2d.position.y = 960
		_player_speed = 50
		mario.no_movement = false
		mario.speed.x = _player_speed
		mario.modulate.a = 1.0
		if mario.global_position.x >= ending_marker.global_position.x:
			_player_speed = 0
			mario.speed.x = 0
			mario.warp = mario.Warp.IN
			@warning_ignore("int_as_enum_without_match", "int_as_enum_without_cast")
			mario.warp_dir = 99
			mario.sprite.speed_scale = 1.0
			mario.sprite.play(&"win")
			end_modulating = false
			_moving = false
			await get_tree().create_timer(1.0, false).timeout
	
			var tw = create_tween()
			tw.tween_property(mario, "modulate:a", 0.0, 0.5)
			tw.tween_property(any_key_label, "modulate:a", 1.0, 1.0)
			any_key_label.modulate.a = 0.0
			any_key.visible = true
			skippable = true
			await tw.finished
			tw = create_tween().set_loops().set_trans(Tween.TRANS_CUBIC)
			tw.tween_property(any_key_label, "modulate:a", 0.6, 0.4)
			tw.tween_property(any_key_label, "modulate:a", 1.0, 0.4)
		return
	
	if _run_away:
		if !slowing_down:
			_player_speed = move_toward(_player_speed, 300, delta * 250)
			cell_peach.speed.x = move_toward(cell_peach.speed.x, 300, delta * 250)
		mario.speed.x = _player_speed
		mario.position.x += _player_speed * delta
		if hud_scrolling:
			var hud = Thunder._current_hud
			hud.get_node("Control").position.x -= _player_speed * delta
			hud.get_node("World").position.x -= _player_speed * delta
		if tp_peach:
			(func():
				if !is_instance_valid(mario): return
				if !tp_peach: return
				cell_peach.global_position.x = mario.global_position.x + 48
			).call_deferred()
		if slowing_down:
			if cell_peach.global_position.x >= ending_marker.global_position.x - 1:
				_player_speed = 0
				tp_peach = false
				_run_away = false
				cell_peach.stop()
				cell_peach.speed.x = 0
				mario.speed.x = 0
				var tw = create_tween()
				tw.tween_property(cell_peach, "modulate:a", 0.0, 0.5)
				await tw.finished
				end_modulating = true
				cell_peach.speed.x = 0
			_player_speed = move_toward(_player_speed, 100, delta * 250)
			mario.speed.x = _player_speed
			return
	
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
		#mario.speed.x = 0
		_moving = false
		restore_camera()
		await get_tree().create_timer(0.2, false).timeout
		if !is_instance_valid(mario): return
		mario.direction = 1
		await get_tree().create_timer(0.5, false).timeout
		if !is_instance_valid(mario): return
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
		if !is_instance_valid(mario): return
		
		_run_away = true
		mario.no_movement = true
		cell_peach.play('walk')
		
		#await get_tree().create_timer(2, false).timeout
		
		#Scenes.current_scene.throw_to_scene()
	
	mario.speed.x = _player_speed


func hud_scroll() -> void:
	control.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
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
	var cam: PlayerCamera2D = Thunder._current_camera
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
		var _tw = create_tween()
		_tw.tween_property(control, "position:x", control.position.x - 640, 2.133333333)
		_tw.tween_callback(func():
			if i == control.get_child_count():
				credit_end()
				return
		)
		await _tw.finished
		#await get_tree().create_timer(3.0 if i == 0 else 6.0, false, false, true).timeout
		await get_tree().create_timer(3.0 if i == 0 else 6.0, false, false, false).timeout
	
func credit_end() -> void:
	const SCR_OFFSET: float = 2848
	var warp_mario: float = wrapf(mario.position.x, SCR_OFFSET, SCR_OFFSET * 2)
	while is_instance_valid(mario) && warp_mario - SCR_OFFSET < 320:
		print("waiting 1 frame..")
		await get_tree().physics_frame
		if !is_inside_tree(): return
	print('ended')
	mario.position.x = warp_mario
	mario.reset_physics_interpolation()
	tp_peach = false
	cell_peach.position.x = mario.position.x + 48
	cell_peach.reset_physics_interpolation()
	
	var cam: PlayerCamera2D = Thunder._current_camera
	cam.global_position = mario.global_position
	cam.reset_physics_interpolation()
	cam.teleport(false, true)
	cam.force_update_transform()
	cam.reset_physics_interpolation()
	cam.force_update_scroll()
	
	parallax_2d.scroll_offset.x = SCR_OFFSET
	parallax_2d.repeat_size.x = 0
	ending.global_position = Vector2(SCR_OFFSET * 2, 2112)
	ending.reset_physics_interpolation()
	await get_tree().physics_frame
	tp_peach = true
	cell_peach.position.x = mario.position.x + 48
	while is_instance_valid(mario) && mario.position.x < 6148:
		await get_tree().physics_frame
		if !is_inside_tree(): return
	slowing_down = true


func _on_cam_area_view_section_changed() -> void:
	if slowing_down: return
	tp_peach = true

	print('[Cutscene] altered time scale from %s' % Engine.time_scale)
	_original_time_scale = Engine.time_scale
	Engine.time_scale = 1

func _restore() -> void:
	if _original_time_scale == 0.0: return
	print('[Cutscene] restored time scale %s' % _original_time_scale)
	Engine.time_scale = _original_time_scale

func _exit_tree() -> void:
	_restore()
