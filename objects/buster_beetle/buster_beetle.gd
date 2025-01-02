extends GeneralMovementBody2D

enum STEPS {
	SEEKING,
	PICKING_UP,
	WAITING_FOR_PLAYER,
	THROWING,
	COOLDOWN
}

@export var player_detection_margin: float = 40
@export var brick_detection_margin: float = 160
@export var cooldown_after_throw: float = 0.5

@onready var ray: RayCast2D = $RayCast2D
@onready var ray2: RayCast2D = $RayCast2D2
@onready var player: Player = Thunder._current_player
@onready var enemy_attacked: Node = $Body/EnemyAttacked

var _step: STEPS = STEPS.SEEKING
var based: Node2D
var player_pos: Vector2

var tw: Tween

func _physics_process(delta: float) -> void:
	if is_queued_for_deletion():
		if tw: tw.kill()
		return
	if is_instance_valid(player): player_pos = player.global_position
	match _step:
		STEPS.SEEKING:
			if is_instance_valid(player) && is_on_floor():
				var spos: Vector2 = global_transform.affine_inverse().basis_xform(global_position)
				var ppos: Vector2 = global_transform.affine_inverse().basis_xform(player.global_position)
				if ppos.y > spos.y - brick_detection_margin && ppos.y < spos.y + brick_detection_margin:
					_check_for_object(ray2 if speed.x > 0 else ray)
			super(delta)
		STEPS.PICKING_UP:
			if based:
				if based.get_class() == &"Node2D":
					based.position.x = move_toward(based.position.x, 0, 100 * delta)
					if based.position.is_equal_approx(Vector2(0, -31)):
						_step = STEPS.WAITING_FOR_PLAYER
				else:
					based.position.x = move_toward(based.position.x, position.x, 100 * delta)
					
					if is_equal_approx(based.position.x, position.x):
						_step = STEPS.WAITING_FOR_PLAYER
			else:
				_step = STEPS.SEEKING
				sprite_node.play(&"default")
				speed.x = 100 if global_position.x > player_pos.x else -100
		STEPS.WAITING_FOR_PLAYER:
			if is_instance_valid(player):
				sprite_node.flip_h = global_position.x > player_pos.x
				var spos: Vector2 = global_transform.affine_inverse().basis_xform(global_position)
				var ppos: Vector2 = global_transform.affine_inverse().basis_xform(player.global_position)
				if ppos.y > spos.y - player_detection_margin && ppos.y < spos.y + player_detection_margin:
					_step = STEPS.THROWING
					sprite_node.animation = &"throw"
					sprite_node.frame = 0
					_throw_logic()


func _throw_logic() -> void:
	var is_brick: bool = &"throwable" in based
	var additional_vector: Vector2 = Vector2.ZERO if is_brick else position
	tw = create_tween().set_trans(Tween.TRANS_CUBIC).set_loops(1) as Tween
	tw.tween_property(based,
		^"position",
		Vector2(5 if sprite_node.flip_h else -5, -29) + additional_vector,
		0.1
	).set_ease(Tween.EASE_OUT)
	tw.tween_property(based,
		^"position",
		Vector2(0, -31) + additional_vector,
		0.1
	).set_ease(Tween.EASE_IN)
	tw.tween_callback(func() -> void:
		var res
		if is_brick:
			res = based.throwable.instantiate()
			
			sprite_node.animation = &"default"
			sprite_node.frame = 0
			sprite_node.speed_scale = 0
			Scenes.current_scene.add_child(res)
			res.get_node(^"Body/EnemyAttacked").stomping_enabled = true
			#res.get_node(^"Attack").enabled = false
			res.global_transform = based.global_transform
			var _sp: float = -300 if sprite_node.flip_h else 300
			res.vel_set_x(_sp)
			res.vel_set_y(-250)
			res.constant_speed = _sp
			based.queue_free()
		elif &"state" in based:
			sprite_node.animation = &"default"
			sprite_node.frame = 0
			sprite_node.speed_scale = 0
			
			if is_instance_valid(based):
				var _sp: float = -400 if sprite_node.flip_h else 400
				based.speed = Vector2(_sp, -350)
				based.state = based.STATES.ENEMY_THROWN
				based = null
		else:
			OS.alert(&"TF DO YOU WANT FROM ME")
	)
	tw.tween_interval(cooldown_after_throw)
	tw.tween_callback(func() -> void:
		if !is_inside_tree() || is_queued_for_deletion(): return
		_step = STEPS.SEEKING
		sprite_node.speed_scale = 1
		sprite_node.play(&"default")
		speed.x = 100 if global_position.x < player_pos.x else -100
	)


func _check_for_object(_ray: RayCast2D) -> void:
	if !_ray.is_colliding(): return
	
	var overlap: Area2D = _ray.get_collider() as Area2D
	if !is_instance_valid(overlap): return
	if !overlap.is_in_group(&"#side_grabbable"): return
	if !overlap.get_parent() is StaticBody2D && !overlap.get_node(^"../..") is GravityBody2D: return
	var object = overlap.get_parent()
	if &"result" in object && object.result:
		_step = STEPS.PICKING_UP
		sprite_node.play(&"pick")
		
		based = object.result.instantiate() as Node2D
		based.is_from_enemy = true
		based._following_pos = Vector2(0, -31)
		add_child(based)
		based.global_position = object.global_position
		if &"timer" in based:
			var timer: Timer = based.timer as Timer
			timer.autostart = false
			timer.stop()
		object.queue_free()
		based.z_index = 1
	elif &"grab_self" in object.get_parent() && object.get_parent().grab_self:
		object = object.get_parent()
		if &"state" in object && object.state == object.STATES.DEFAULT:
			_step = STEPS.PICKING_UP
			sprite_node.play(&"pick")
			
			object._following_pos = position + Vector2(0, -31)
			object._ready_grabbed(self)
			object.z_index = 1
			based = object


var enemy_killed = preload("res://engine/objects/enemies/_dead/enemy_killed.tscn")

func _killed(_speed: Vector2) -> void:
	if !is_instance_valid(based): return
	
	var death_node: AnimatedSprite2D = based.get_node(^"Sprite").duplicate()
	if !death_node: return
	
	death_node.visible = true
	if &"flip_v" in death_node: death_node.flip_v = true
	death_node.speed = _speed
	#node.add_child(death_node)
