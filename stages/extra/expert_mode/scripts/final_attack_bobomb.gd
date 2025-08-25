extends BowserAttack

const GOOMBA_BRO = preload("res://stages/extra/expert_mode/objects/8-4_goomba_bro.tscn")

@export var wait_time: float = 3.0
@export_group("Movement")
@export var lock_movement: bool = true
@export var lock_direction: bool = false

func start_attack() -> void:
	super()
	
	# Animation modification
	#bowser.sprite.play(animation_pre)
	#bowser.sprite.offset.x = sprite_offset_x * bowser.facing
	#bowser.sprite.reset_physics_interpolation()
	middle_attack()


func middle_attack() -> void:
	super()
	var pl: Player = Thunder._current_player
	if !pl: return
	var bropos_x = 654 if pl.global_position.x < 320 else -14
	var goomba_bro = GOOMBA_BRO.instantiate()
	goomba_bro.position = Vector2(bropos_x, 336)
	
	Scenes.current_scene.add_child(goomba_bro)
	# Tween for processing attack
	var tween: Tween = create_tween()
	tween.tween_interval(wait_time)
	# Tween to end the process and restore data
	tween.tween_callback(end_attack)

func end_attack() -> void:
	super()
