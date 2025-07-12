extends Area2D

@export_category("Phantomic Podoboo")
@export_group("Physics")
@export var gravity_acceleration: float = 500
@export var acceleration: float = 1250

var velocity: Vector2

var tween: Tween
var accelerating: int

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	global_position += velocity * delta
	velocity += Vector2.DOWN * gravity_acceleration * delta
	
	if accelerating == 0:
		global_rotation = velocity.angle()
		if velocity.normalized().dot(Vector2.UP) < 0:
			var player: Player = Thunder._current_player
			if !player || tween:
				return
			
			accelerating = 1
			velocity = Vector2.ZERO
			gravity_acceleration = 0
			tween = create_tween().set_trans(Tween.TRANS_SINE)
			tween.tween_property(self, "global_rotation", global_position.angle_to_point(player.global_position), 0.25)
			tween.tween_callback(
				func() -> void:
					accelerating = 2
			)
	elif accelerating == 2:
		velocity += Vector2.RIGHT.rotated(global_rotation) * acceleration * delta


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	if velocity.normalized().dot(Vector2.DOWN) > 0:
		queue_free()
		return
	if global_position.distance_squared_to(get_viewport_transform().affine_inverse().get_origin() + get_viewport_rect().size/2) > 512 ** 2:
		queue_free()
