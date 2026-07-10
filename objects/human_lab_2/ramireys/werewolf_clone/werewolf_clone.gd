extends GeneralMovementBody2D

const TRIGGER = preload("res://objects/human_lab_2/ramireys/werewolf_clone/sfx/trigger.wav")
const ATTACK = preload("res://objects/human_lab_2/ramireys/werewolf_clone/sfx/attack.wav")
const LAND = preload("res://objects/human_lab_2/ramireys/werewolf_clone/sfx/land.wav")

enum STATE {
	DEFAULT,
	RUNNING,
	ATTACKING,
	KNOCKED,
}

@export var collision_shapers: Array[Shaper2D]
@export var explosion_effect: PackedScene = preload("res://engine/objects/effects/explosion/explosion.tscn")

@onready var coll: CollisionShape2D = $Collision
@onready var body_coll: CollisionShape2D = $Body/Collision
@onready var left_explosion: RayCast2D = $LeftExplosion
@onready var right_explosion: RayCast2D = $RightExplosion
@onready var enemy_attacked: Node = $Body/EnemyAttacked

var state: int
var cooldown: float
var attack_delay: float
var is_running: bool
var audio_ref: AudioStreamPlayer2D

var pl: Player

func _physics_process(delta: float) -> void:
	motion_process(delta, slide)
	
	if turn_sprite && sprite_node && is_instance_valid(sprite_node):
		if speed.x != 0:
			sprite_node.flip_h = speed.x < 0
		else:
			sprite_node.flip_h = dir == -1
	
	pl = Thunder._current_player
	match state:
		STATE.DEFAULT:
			state_default(delta)
		STATE.RUNNING:
			state_running(delta)
		STATE.ATTACKING:
			state_attacking(delta)


func state_default(delta: float) -> void:
	cooldown = min(cooldown + Thunder.get_delta(delta), 35)
	if cooldown < 35:
		return
	
	if is_player_in_bounds(225):
		trigger()


func state_running(delta: float) -> void:
	attack_delay = min(attack_delay + Thunder.get_delta(delta), 35)
	if attack_delay < 35:
		speed.x = 0
		return
	
	if !is_running:
		is_running = true
		speed.x = 200 * dir
		sprite_node.play(&"default")
	
	if is_player_in_bounds(140) && is_on_floor():
		attack()


func state_attacking(delta: float) -> void:
	if is_on_floor():
		land()


func trigger() -> void:
	Audio.play_sound(TRIGGER, self, false)
	state = STATE.RUNNING
	update_dir()
	speed.x = 0
	sprite_node.flip_h = dir == -1
	is_running = false
	attack_delay = 0
	sprite_node.play(&"alert")


func attack() -> void:
	audio_ref = Audio.play_sound(ATTACK, self, false)
	state = STATE.ATTACKING
	sprite_node.play(&"attack")
	gravity_scale = 0.2
	speed.x = 100 * dir
	jump(350)
	is_running = false


func land() -> void:
	Audio.play_sound(LAND, self, false)
	state = STATE.KNOCKED
	sprite_node.play(&"knocked")
	@warning_ignore("narrowing_conversion")
	dir = signi(speed.x)
	speed.x = 0
	collision_shapers[2].install_shape_for(coll)
	collision_shapers[2].install_shape_for(body_coll)
	enemy_attacked.stomping_offset.y = 16
	sprite_node.offset.y = 4
	var tw = sprite_node.create_tween()
	tw.tween_property(sprite_node, ^"offset:y", 0.0, 0.08)
	
	process_bumping_blocks()
	
	_explosion()


func _on_sprite_frame_changed() -> void:
	if sprite_node.animation == &"attack" && sprite_node.frame == 1:
		collision_shapers[1].install_shape_for(coll)
		collision_shapers[1].install_shape_for(body_coll)
		enemy_attacked.stomping_offset.y = 16


func _on_sprite_animation_finished() -> void:
	if sprite_node.animation == &"knocked":
		reset_to_default_state()

func reset_to_default_state() -> void:
	collision_shapers[0].install_shape_for(coll)
	collision_shapers[0].install_shape_for(body_coll)
	state = STATE.DEFAULT
	gravity_scale = 0.5
	speed.x = 50 * dir
	cooldown = 0
	sprite_node.play(&"default")
	# fix for instadeath of player when changing shapes
	await get_tree().physics_frame
	await get_tree().physics_frame
	enemy_attacked.stomping_offset.y = 0


func is_player_in_bounds(margin: float) -> bool:
	if !pl:
		return false
	return absf(
		global_transform.affine_inverse().basis_xform(pl.global_position).x - global_transform.affine_inverse().basis_xform(global_position).x
	) <= margin


func _explosion() -> void:
	NodeCreator.prepare_2d(explosion_effect, self).bind_global_transform(left_explosion.position).create_2d().call_method(
		func(eff: Node2D) -> void:
			left_explosion.force_raycast_update()
			if !left_explosion.is_colliding():
				eff.queue_free()
	)
	NodeCreator.prepare_2d(explosion_effect, self).bind_global_transform(right_explosion.position).create_2d().call_method(
		func(eff: Node2D) -> void:
			right_explosion.force_raycast_update()
			if !right_explosion.is_colliding():
				eff.queue_free()
	)


func _kill_sounds() -> void:
	if is_instance_valid(audio_ref):
		audio_ref.queue_free()


func process_bumping_blocks() -> void:
	var query := PhysicsShapeQueryParameters2D.new()
	query.collision_mask = collision_mask
	query.motion = Vector2(clamp(speed_previous.x, -1, 1), clamp(speed_previous.y, -1, 1)).rotated(global_rotation)
	
	for i in get_shape_owners():
		query.transform = (shape_owner_get_owner(i) as Node2D).global_transform
		for j in shape_owner_get_shape_count(i):
			query.shape = shape_owner_get_shape(i, j)
			
			var cldata: Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(query)
			
			for k in cldata:
				var l: Object = k.get(&"collider", null)
				#var id: int = k.get(&"collider_id", 0)
				
				if l is StaticBumpingBlock:
					if l.has_method(&"got_bumped"):
						l.got_bumped.call_deferred(false, false)
					elif l.has_method(&"bricks_break"):
						l.bricks_break.call_deferred()
