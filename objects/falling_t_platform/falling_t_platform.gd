extends AnimatableBody2D

@export_range(0, 360, 0.01, "radians_as_degrees", "or_greater") var rotation_acceleration: float = TAU/360
@export_range(0, 10, 0.01, "or_greater", "suffix:x") var falling_acceleration_ratio: float = 0.2

var arm: float
var stop: bool

var velocity: Vector2
var angular_vel: float

@onready var sprite_top: Node2D = $SpriteTop
@onready var visible_on_screen_enabler_2d: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D
@onready var sound_crash: AudioStreamPlayer2D = $SoundCrash
@onready var sound_boom: AudioStreamPlayer2D = $SoundBoom


func _physics_process(delta: float) -> void:
	if is_zero_approx(arm):
		var kc := KinematicCollision2D.new()
		test_move(global_transform, Vector2.UP.rotated(global_rotation) * 4, kc)
		
		var col := kc.get_collider()
		if !col:
			return
		elif (col is GravityBody2D && col.is_on_floor()) || (col.is_in_group(&"t_platform")):
			var l := kc.get_position() - global_position
			var n := Vector2.RIGHT.rotated(global_rotation)
			arm = sign(l.dot(n))
			
			var cam := get_viewport().get_camera_2d() as PlayerCamera2D
			if cam:
				cam.shock(1.75, Vector2(3, 0))
			sound_crash.play()
			
			visible_on_screen_enabler_2d.queue_free()
	elif is_equal_approx(absf(arm), 1.0):
		angular_vel += rotation_acceleration * delta * signf(arm)
		rotation_acceleration += rotation_acceleration * 0.2 * delta
		global_rotation += angular_vel * delta
	
	if absf(global_rotation) > PI/4 && !stop:
		velocity += PhysicsServer2D.body_get_direct_state(get_rid()).total_gravity * delta
		global_position += velocity * delta
		
		if sprite_top.get_global_transform_with_canvas().get_origin().y > sprite_top.get_viewport_rect().size.y + 192:
			collision_layer = 0
			collision_mask = 0
			velocity = Vector2.ZERO
			stop = true
			
			var cam := get_viewport().get_camera_2d() as PlayerCamera2D
			if cam:
				cam.shock(1.5, Vector2(12 * (1 - clampf(inverse_lerp(0, 1280, cam.get_screen_center_position().distance_to(global_position)), 0, 1)), 0))
				sound_boom.play()
				await get_tree().create_timer(3, false, true).timeout
				queue_free()
