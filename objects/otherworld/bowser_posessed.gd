extends "res://engine/objects/bosses/bowser/bowser.gd"

const BOWSER_HUD = preload("res://objects/otherworld/bowser_hud.tscn")

var is_following: bool
var _following_start: bool
var _follow_progress: float
var _to_follow_pos: Vector2
var _from_follow_pos: Vector2
var _chase_speed: float

func _ready() -> void:
	_correct_collision()
	sprite.animation_looped.connect(_on_sprite_animation_looped)
	_speed = speed.x
	facing = get_facing(facing)
	direction = facing
	vel_set_x(0)
	#enemy_attacked.killing_immune = {}
	if tweaked_stomping:
		enemy_attacked.stomping_player_jumping_max = enemy_attacked.stomping_player_jumping_min
	
	# HUD
	hud = BOWSER_HUD.instantiate()
	hud.bowser = self
	hud.y_offset = y_offset
	health_changed.connect(hud.life_changed)
	add_sibling.call_deferred(hud)
	
	chase_and_follow(150)

func chase_and_follow(speed: float) -> void:
	var pl: Player = Thunder._current_player
	if !pl: return
	if pl.global_position < global_position:
		_chase_speed = -abs(speed)
	else:
		_chase_speed = abs(speed)
	
	gravity_scale = 0.15
	_follow_progress = 0.0
	_following_start = false

func stop_following(set_gravity: bool = true) -> void:
	_follow_progress = 0.0
	_following_start = false
	is_following = false
	_chase_speed = 0
	if set_gravity:
		gravity_scale = 0.15

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
			tween_status.get_total_elapsed_time(), tween_status.is_running(), tween_status.get_loops_left()
		]
	
	var pl: Player = Thunder._current_player
	if !pl:
		stop_following(true)
	
	if !is_following:
		vel_set_x(_chase_speed)
		if pl && (_chase_speed < 0 && global_position.x < pl.global_position.x) || (_chase_speed > 0 && global_position.x > pl.global_position.x):
			gravity_scale = 0
			is_following = true
			_following_start = true
		else:
			if is_on_floor() && sprite.animation == &"jump" || !sprite.is_playing():
				sprite.play(&"default")
			if sprite.animation == &"default" && !is_on_floor():
				sprite.play(&"jump")
		
		if !pl && sprite.animation == &"default":
			sprite.stop()
		# Physics
		motion_process(delta)
		if is_on_floor():
			pos_y_on_floor = global_transform.affine_inverse().basis_xform(global_position).y
	
	debug_text.visible = Console.cv.player_stats_shown
	
	# Old bowser stomping (Tweak)
	if tweaked_stomping && _tweaked_stomping_vel:
		if is_instance_valid(player) && !player.is_on_wall():
			player.position.x += _tweaked_stomping_vel * 50 * delta
		_tweaked_stomping_vel = move_toward(_tweaked_stomping_vel, 0.0, 50 * delta)
	
	if !is_following: return
	var pos: Vector2 = pl.global_position - Vector2(1, 16)
	var on_floor: bool = pl.is_on_floor()
	if _following_start:
		#print(_follow_progress)
		if _follow_progress == 0:
			_from_follow_pos = global_position
			_to_follow_pos = pos
		global_position = lerp(_from_follow_pos, _to_follow_pos, Thunder.Math.ease_out_back(_follow_progress))
		_follow_progress = min(_follow_progress + 1.25 * delta, 1)
		gravity_scale = 0.05
		if _follow_progress == 1:
			_follow_progress = 0
			_following_start = false
			gravity_scale = 0
		
		motion_process(delta)
		
		if sprite.animation == &"default" && !is_on_floor():
			sprite.play(&"jump")
	
	if !pl: return
	get_tree().create_timer(0.8, false, true, false).timeout.connect(func():
		#if !is_instance_valid(mario):
		#	kevin_podokh()
		#	return
		if !Thunder._current_player: return
		global_position = pos
		if on_floor && sprite.animation == &"jump" || !sprite.is_playing():
			sprite.play(&"default")
		if sprite.animation == &"default" && !on_floor:
			sprite.play(&"jump")
	)
	
