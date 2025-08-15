extends PathFollow2D

@export_category("Platform")
@export var no_ambience_audio: bool = false
@export var ambience_volume_db: float = -2
@export_group("Physics")
@export var speed: float = 150.0
@export var loop_backwards: bool = true
@export var warp_objects_on_end: bool = true
@export var warping_edge_ignore_px: float = 8.0
@export_subgroup("Smooth","smooth_")
@export var smooth_enabled: bool = true
@export var smooth_turning_length: float = 64.0
@export var smooth_turning_duration_fixer: float = 0.105
@export var smooth_points:PackedInt32Array

var smooth_speed: float
var smooth_duration: float
var smooth_next_points: PackedVector2Array
var smooth_on_continue_point: bool
var smooth_step: int
var smooth_counter: float
#var rotating: bool

var linear_velocity: Vector2

@onready var curve: Curve2D = (
	func() -> Curve2D:
		if !get_parent() is Path2D: return null
		return get_parent().curve
).call()
@onready var max_progress: float = (
	func() -> float:
		if !curve: return 0.0
		var max_length: float
		var current: float = progress_ratio
		progress_ratio = 1.0
		max_length = progress
		progress_ratio = current
		return max_length
).call()
@onready var sprite: Sprite2D = $Sprite2D

# Block movement of the platform in scripts
var _movement_blocked: bool = false

func _ready() -> void:
	if no_ambience_audio:
		$AudioStreamPlayer2D.queue_free()
	elif ambience_volume_db:
		$AudioStreamPlayer2D.volume_db = ambience_volume_db
	if smooth_turning_length > 0: _sign_up_points()

func _physics_process(delta: float) -> void:
	sprite.rotation_degrees += delta * 225# * clampf(speed, -10, 10)
	if get_child_count() == 0: return
	
	_on_path_movement_process(delta)
	
	if warp_objects_on_end: return
	if max_progress < warping_edge_ignore_px: return
	if progress < warping_edge_ignore_px || progress + warping_edge_ignore_px > max_progress:
		reset_physics_interpolation()


func _on_path_movement_process(delta: float) -> void:
	#if !on_path: return
	if _movement_blocked: return
	
	if curve:
		progress += speed * delta
		if loop:
			return
		if smooth_enabled && smooth_turning_length > 0: _smooth_movement(delta)
		else: _sharp_movement()
	#
	#if falling_acceleration != 0:
		#position += linear_velocity * Thunder.get_delta(delta)
	
	#linear_velocity = (global_position - pos) / delta
	# Emit Falling
	#if on_path && players_have_stood && falling_acceleration > 0.0 && falling_enabled:
	#	on_path = false


#func _non_path_movement_process(delta: float) -> void:
	#if on_path: return
	#if _movement_blocked: return
	#
	# Falling
	#if players_have_stood && falling_acceleration != 0 && falling_enabled:
		#linear_velocity += falling_direction.normalized() * falling_acceleration * delta
	#
	#global_position += linear_velocity * Thunder.get_delta(delta)


func _sharp_movement() -> void:
	if !curve: return
	if loop_backwards && (progress_ratio <= 0 || progress_ratio >= 1): speed *= -1

func _smooth_movement(delta: float) -> void:
	if !curve: return
	
	smooth_on_continue_point = !smooth_next_points.is_empty()
	match smooth_step:
		0:
			var start:float = 0.0
			var end:float = max_progress
			var next_point_progress:float
			
			if smooth_on_continue_point: 
				next_point_progress = curve.get_closest_offset(smooth_next_points[0])
				if speed > 0: end = next_point_progress
				elif speed < 0: start = next_point_progress
			
			if (speed > 0.0 && progress >= end - smooth_turning_length) || (speed < 0.0 && progress <= start + smooth_turning_length):
				smooth_speed = speed
				smooth_duration = smooth_turning_length / abs(smooth_speed) + smooth_turning_duration_fixer
				smooth_step = 1
				#if rotates:
					#rotates = false
					#rotating = true
					#var _tw = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_trans(Tween.TRANS_SINE)
					#_tw.tween_property(self, "smooth_counter", 1.0, smooth_duration * 2).from(0.0)
					#_tw.tween_callback(set.bind("rotating", false))
					#_tw.tween_callback(set.bind("rotates", true))
		1:
			var tw:Tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_trans(Tween.TRANS_SINE)
			tw.tween_property(self, "speed", 0, smooth_duration)
			tw.tween_property(self, "speed", smooth_speed if smooth_on_continue_point else -smooth_speed, smooth_duration)
			tw.tween_callback(
				func() -> void: 
					if smooth_on_continue_point: smooth_next_points.remove_at(0)
					else: _sign_up_points()
					smooth_step = 0
			)
			smooth_step = 2
	#if rotating:
		#var angle = curve.sample_baked_with_rotation(progress + curve.bake_interval).get_rotation()
		#var angle = curve.get_closest_point(smooth_next_points[0]).angle()
		#rotation = lerp_angle(rotation, angle, smooth_counter)


func _sign_up_points() -> void:
	for i in smooth_points: smooth_next_points.append(curve.get_point_position(i))
	if speed < 0.0: smooth_next_points.reverse()
