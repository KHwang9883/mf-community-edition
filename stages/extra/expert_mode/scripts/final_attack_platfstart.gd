extends BowserAttack

@export var wait_time: float = 1.5
@export_group("Movement")
@export var lock_movement: bool = true
@export var lock_direction: bool = false
@export var burst_attack_offset_from_screen_border: float = 80

@onready var platf: Node2D = $"../AmazingPlatf"

func start_attack() -> void:
	super()
	bowser.jump_enabled = false
	
	var able_to_attack: bool = false
	while is_inside_tree() && is_instance_valid(bowser) && !able_to_attack:
		if bowser.is_on_floor():
			var bowser_origin: float = bowser.get_global_transform_with_canvas().get_origin().x
			able_to_attack = (
				bowser_origin > burst_attack_offset_from_screen_border &&
				bowser_origin < bowser.get_viewport_rect().size.x - burst_attack_offset_from_screen_border
			)
		await get_tree().physics_frame
	
	bowser.lock_movement = lock_movement
	bowser.lock_direction = lock_direction
	
	# Animation modification
	#bowser.sprite.play(animation_pre)
	#bowser.sprite.offset.x = sprite_offset_x * bowser.facing
	#bowser.sprite.reset_physics_interpolation()
	middle_attack()


func middle_attack() -> void:
	super()
	bowser.jump(bowser.jumping_speed + 100)
	await get_tree().create_timer(0.3, false, true, false).timeout
	# Tween for processing attack
	var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.3)
	tween.tween_property(platf, "modulate:a", 1.0, 0.3).from(0.0)
	tween.chain().tween_property(platf, "position:y", 48, 1.0).set_ease(Tween.EASE_IN)
	
	# Tween to end the process and restore data
	tween.tween_callback(end_attack)


func end_attack() -> void:
	super()
