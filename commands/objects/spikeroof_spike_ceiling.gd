extends "res://engine/objects/enemies/spike_ceiling/spike_ceiling.gd"

const _ENTRANCE_SLIDE_SPEED: float = 280.0
const _SPAWN_CLEAR_MARGIN: float = 8.0

var _level_finished: bool
var _entrance_tween: Tween

func _ready() -> void:
	super()
	_set_hazard_enabled(false)
	visible = false
	var scene: Node = Scenes.current_scene
	if scene && scene.has_signal(&"level_completed"):
		scene.level_completed.connect(_on_level_finished)
	get_tree().physics_frame.connect(_run_safe_entrance, CONNECT_ONE_SHOT)


func _physics_process(delta: float) -> void:
	if !_level_finished:
		var player: Player = Thunder._current_player
		if player && player.completed:
			_on_level_finished()
	if _level_finished:
		_process_finished(delta)
		return
	super(delta)


func _run_safe_entrance() -> void:
	if _level_finished:
		return
	_set_hazard_enabled(false)
	visible = false
	var rest_pos: Vector2 = init_pos
	position = rest_pos - _fall_dir() * _entrance_slide_distance()
	reset_physics_interpolation()
	
	var scene: Node = Scenes.current_scene
	if scene && scene.has_signal(&"stage_ready") && !scene.get(&"_is_stage_ready"):
		await scene.stage_ready
	if !_can_continue_entrance():
		return
	# CamArea / parallax can still settle a frame or two after stage_ready.
	for i in 3:
		await get_tree().physics_frame
		if !_can_continue_entrance():
			return
	
	while _can_continue_entrance() && _player_blocks_rest_pose():
		await get_tree().physics_frame
	if !_can_continue_entrance():
		return
	
	visible = true
	reset_physics_interpolation()
	var duration: float = maxf(position.distance_to(rest_pos) / _ENTRANCE_SLIDE_SPEED, 0.05)
	_entrance_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_entrance_tween.tween_property(self, "position", rest_pos, duration)
	await _entrance_tween.finished
	if !_can_continue_entrance():
		return
	position = rest_pos
	reset_physics_interpolation()
	_set_hazard_enabled(true)


func _on_level_finished() -> void:
	if _level_finished:
		return
	_level_finished = true
	if is_instance_valid(_entrance_tween) && _entrance_tween.is_running():
		_entrance_tween.kill()
	timer.stop()
	_sine = 0
	_falling_vel = 0
	_set_kill_area_enabled(false)
	visible = true
	if position.is_equal_approx(init_pos):
		_state = 0
	else:
		_state = 4
	set_physics_process(true)


func _process_finished(delta: float) -> void:
	if _state != 4:
		return
	position = position.move_toward(init_pos, reabilitation_speed * delta)
	if position.is_equal_approx(init_pos):
		position = init_pos
		_state = 0


func _can_continue_entrance() -> bool:
	return is_instance_valid(self) && !_level_finished


func _set_hazard_enabled(enabled: bool) -> void:
	if !enabled:
		timer.stop()
	_set_kill_area_enabled(enabled)
	set_physics_process(enabled)


func _set_kill_area_enabled(enabled: bool) -> void:
	area.monitoring = enabled
	area.set_physics_process(enabled)


func _player_blocks_rest_pose() -> bool:
	var player: Player = Thunder._current_player
	if !is_instance_valid(player) || player.is_dying:
		return true
	return _rest_spike_aabb().grow(_SPAWN_CLEAR_MARGIN).intersects(_player_aabb(player))


func _entrance_slide_distance() -> float:
	return maxf(spike.size.y, 32.0) + 96.0


func _rest_spike_aabb() -> Rect2:
	var rest_xf: Transform2D = get_transform()
	rest_xf.origin = init_pos
	var parent_node := get_parent() as Node2D
	var xf: Transform2D = parent_node.global_transform * rest_xf if parent_node else rest_xf
	var spike_h: float = maxf(spike.size.y, 32.0)
	var top_left := Vector2(0, size.y - spike_h)
	var rect := Rect2(xf * top_left, Vector2.ZERO)
	rect = rect.expand(xf * (top_left + Vector2(size.x, 0)))
	rect = rect.expand(xf * (top_left + Vector2(size.x, spike_h)))
	return rect.expand(xf * (top_left + Vector2(0, spike_h)))


func _player_aabb(player: Player) -> Rect2:
	if is_instance_valid(player.collision_shape) && player.collision_shape.shape is RectangleShape2D:
		return _collision_aabb(player.collision_shape)
	return Rect2(player.global_position - Vector2(16, 32), Vector2(32, 64))


func _collision_aabb(cs: CollisionShape2D) -> Rect2:
	var rect_shape := cs.shape as RectangleShape2D
	var half := rect_shape.size * 0.5
	var xf: Transform2D = cs.global_transform
	var rect := Rect2(xf * -half, Vector2.ZERO)
	rect = rect.expand(xf * Vector2(half.x, -half.y))
	rect = rect.expand(xf * half)
	return rect.expand(xf * Vector2(-half.x, half.y))
