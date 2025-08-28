extends BowserAttack

const BOB_OMB_INSTANTIATER = preload("res://objects/volcano/bob_omb/bob_omb_instantiater.tscn")

@export var throw_sound: AudioStream = preload("res://engine/objects/projectiles/sounds/throw.wav")
@export var wait_time: float = 1.2
@export_group("Movement")
@export var lock_movement: bool = true
@export var lock_direction: bool = false
@export var sprite_offset_x: float = 7

@onready var pos_bobomb: Marker2D = $"../PosBobomb"
@onready var pos_bobomb_x: float = pos_bobomb.position.x

func _physics_process(delta: float) -> void:
	if bowser && bowser.sprite.animation == "bobomb":
		pos_bobomb.position.x = pos_bobomb_x * bowser.facing
		bowser.sprite.offset.x = sprite_offset_x * bowser.facing
		bowser.sprite.reset_physics_interpolation()

func start_attack() -> void:
	while is_inside_tree() && !bowser.is_on_floor():
		await get_tree().physics_frame
	super()
	bowser.lock_movement = lock_movement
	bowser.lock_direction = lock_direction
	
	# Animation modification
	bowser.sprite.play(&"bobomb")
	bowser.sprite.offset.x = sprite_offset_x * bowser.facing
	bowser.sprite.reset_physics_interpolation()
	middle_attack()


func middle_attack() -> void:
	super()
	# Tween for processing attack
	var tween_hammer: Tween = create_tween()
	tween_hammer.tween_interval(wait_time)
	tween_hammer.tween_callback(
		func() -> void:
			var bobomb = BOB_OMB_INSTANTIATER.instantiate()
			bobomb.get_child(0).self_ignite_after_sec = 1.5
			bobomb.get_child(0).wait_for_explosion_for_sec = 2.0
			bobomb.speed_x = 200
			bobomb.speed_y = -400
			bobomb.speed_x_go_to = 125
			bobomb.get_child(0).force_direction = bowser.facing
			bobomb.position = pos_bobomb.global_position
			bowser.add_sibling(bobomb)
			Audio.play_sound(throw_sound, bowser, false)
	)
	# Tween to end the process and restore data
	tween_hammer.tween_callback(end_attack)

func end_attack() -> void:
	super()
	bowser.sprite.offset.x = 0
	bowser.sprite.play(&"default")
	bowser.lock_movement = false
	bowser.lock_direction = false
