extends GravityBody2D

const ADD_EFFECT = preload("./materials/add_effect.tres")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	motion_process(delta)
	
	var is_flipped: bool = speed.x < 0
	sprite.flip_h = is_flipped


func _on_timer_timeout() -> void:
	if !is_instance_valid(sprite): return
	# Trail effect
	Effect.trail(
		self,
		sprite.sprite_frames.get_frame_texture(&"trail", randi_range(0, 3)),
		sprite.position,
		sprite.flip_h,
		sprite.flip_v,
		true,
		0.02,
		1.0,
		ADD_EFFECT
	)
