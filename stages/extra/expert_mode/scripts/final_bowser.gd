extends "res://engine/objects/bosses/bowser/bowser.gd"

func _physics_process(delta: float) -> void:
	# Direction
	if !lock_direction:
		facing = get_facing(facing)
		if sprite.animation == &"throw":
			sprite.offset.x = 7 * facing
			sprite.reset_physics_interpolation()
	
	# Animation
	if facing != 0:
		sprite.flip_h = (facing < 0)
	
	if !active: return
	if is_on_floor() && sprite.animation == &"jump" || !sprite.is_playing():
		sprite.play(&"default")
	if sprite.animation == &"default" && !is_on_floor():
		sprite.play(&"jump")
	
	# Pos markers
	#pos_flame.position.x = pos_flame_x * facing
	#pos_hammer.position.x = pos_hammer_x * facing
	
	# Movement
	if !lock_movement:
		_movement(delta)
	elif speed.x != 0:
		_speed = abs(speed.x)
		vel_set_x(0)
	
	# Jump
	if jump_enabled:
		_jumping(delta)
	
	# Attack
	if !tween_status:
		tween_status = create_tween()
		for i in status.size():
			tween_status.tween_interval(status_interval[i])
			tween_status.tween_callback(attack.bind(status[i]))
		if _attacking:
			tween_status.pause()
		tween_status.finished.connect(func() -> void:
			tween_status = null
		)
	else:
		debug_text.text = debug_text_template % [
			tween_status.get_total_elapsed_time(), tween_status.is_running(),
			tween_status.get_loops_left(), _speed
		]
	
	# Physics
	motion_process(delta)
	if is_on_floor():
		pos_y_on_floor = 320 #global_transform.affine_inverse().basis_xform(global_position).y
	
	debug_text.visible = Console.cv.player_stats_shown
	
	# Old bowser stomping (Tweak)
	if !tweaked_stomping || !_tweaked_stomping_vel: return
	if is_instance_valid(player) && !player.is_on_wall():
		player.position.x += _tweaked_stomping_vel * 50 * delta
	_tweaked_stomping_vel = move_toward(_tweaked_stomping_vel, 0.0, 50 * delta)
