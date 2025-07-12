extends Area2D

const EXPLOSION: PackedScene = preload("res://engine/objects/effects/explosion/explosion.tscn")

@export_category("Phantomic Thwomp")
@export_group("Physics")
@export var falling_acceleration: float = 7500
@export var returning_speed: float = 200
@export_group("Stun")
@export var pre_stunning_range: float = 128
@export var stunning_range: float = 96
@export var stunning_waiting_duration: float = 1.5
@export var ready_to_stun_delay: float = 0.75
@export_group("Sound")
@export var stunning_sound: AudioStream = preload("res://engine/objects/projectiles/sounds/stun.wav")

var velocity: Vector2

var origin: Vector2
var step: int

@onready var visible_on_screen_enabler_2d: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bottom: ShapeCast2D = $Bottom
@onready var left_explosion: RayCast2D = $LeftExplosion
@onready var right_explosion: RayCast2D = $RightExplosion


func _physics_process(delta: float) -> void:
	match step:
		# Idle
		0:
			visible_on_screen_enabler_2d.enable_node_path = ^".."
			velocity = Vector2.ZERO
			sprite.play(&"default")
			
			var player: Player = Thunder._current_player
			if !player:
				return
			
			var trans: Transform2D = global_transform.affine_inverse()
			var ppos: Vector2 = trans.basis_xform(player.global_position)
			var pos: Vector2 = trans.basis_xform(global_position)
			if ppos.x > pos.x - pre_stunning_range && ppos.x < pos.x + pre_stunning_range:
				sprite.play(&"ready")
			if ppos.x > pos.x - stunning_range && ppos.x < pos.x + stunning_range:
				origin = global_position
				step = 1
		# Stunning
		1:
			visible_on_screen_enabler_2d.enable_node_path = ^"."
			global_position += velocity * delta
			velocity += Vector2.DOWN.rotated(global_rotation) * falling_acceleration * delta
			
			sprite.play(&"stun")
			
			#Effect.trail(self, sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame))
			bottom.force_shapecast_update()
			if bottom.is_colliding():
				Audio.play_sound(stunning_sound, self)
				Thunder._current_camera.shock(0.2, Vector2.ONE * 8)
				velocity = Vector2.ZERO
				while bottom.is_colliding():
					global_position += Vector2.UP.rotated(global_rotation)
					bottom.force_shapecast_update()
				NodeCreator.prepare_2d(EXPLOSION, self).bind_global_transform(left_explosion.position).create_2d().call_method(
					func(eff: Node2D) -> void:
						left_explosion.force_raycast_update()
						if !left_explosion.is_colliding():
							eff.queue_free()
				)
				NodeCreator.prepare_2d(EXPLOSION, self).bind_global_transform(right_explosion.position).create_2d().call_method(
					func(eff: Node2D) -> void:
						right_explosion.force_raycast_update()
						if !right_explosion.is_colliding():
							eff.queue_free()
				)
				
				step = 2
		2:
			await get_tree().create_timer(stunning_waiting_duration, false, true).timeout
			step = 3
		# Rising
		3:
			global_position += velocity * delta
			sprite.play(&"default")
			velocity = Vector2.UP.rotated(global_rotation) * returning_speed
			
			var dot: float = global_position.direction_to(origin).dot(velocity.normalized())
			if dot < 0:
				global_position = origin
				velocity = Vector2.ZERO
				step = 4
		# Waiting for next stunning
		4:
			await get_tree().create_timer(ready_to_stun_delay, false, true).timeout
			step = 0
