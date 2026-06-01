extends GravityBody2D

signal health_changed(to: int)

const HUD: PackedScene = preload("res://engine/objects/bosses/bowser/bowser_hud.tscn")
const CORPSE: PackedScene = preload("res://engine/objects/bosses/bowser/corpse/bowser_corpse.tscn")
const LAUGHING = preload("res://engine/objects/enemies/thwomp/sounds/laughing.wav")

@export_category("Bowser")
@export_group("Health")
@export var health: int = 5:
	set(to):
		health = to
		(func() -> void: health_changed.emit(health)).call_deferred()
## Projectile health, will remove a point from [member health] when it hits 0
@export var hardness: int = 5
@export var invincible_duration: float = 2
@export var instakill_from_lava: bool = true
@export_subgroup("Sounds")
@export var hurt_sound: AudioStream = preload("res://engine/objects/bosses/bowser/sounds/bowser_hurt.wav")
@export var death_sound: AudioStream = preload("res://engine/objects/bosses/bowser/sounds/bowser_died.wav")
@export var falling_sound: AudioStream = preload("res://engine/objects/bosses/bowser/sounds/bowser_fall.wav")
@export var into_lava_sound: AudioStream = preload("res://engine/objects/bosses/bowser/sounds/bowser_into_lava.wav")
@export_group("Status")
@export var status_interval: Array[float] = [3]
@export var status: Array[StringName] = [&"flame"]
@export_group("Level Setting")
@export var finish_on_death: bool = true
@export_enum("Left: -1", "Right: 1") var complete_direction: int = 1
@export_group("HUD")
@export var y_offset: int = 0

var tween_hurt: Tween
var tween_hurt_blinking: Tween
var tween_status: Tween

var active: bool
var direction: int
var facing: int
var lock_direction: bool
var lock_movement: bool = true
var jump_enabled: bool = true

var trigger: Node2D

var pos_y_on_floor: float

var _speed: float
var _walking_counter: float
var _walking_move_distance: float

var _bullet_received: float

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var skull: AnimatedSprite2D = $BaseSprite/Skull
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var enemy_attacked: Node = $Body/EnemyAttacked
@onready var debug_text: Label = $Debug
@onready var debug_text_template: String = debug_text.text

@onready var initial_killing_immune: Dictionary = enemy_attacked.killing_immune.duplicate(true)
#@onready var tweaked_stomping: bool = SettingsManager.get_tweak("bowser_stomping", false)
@onready var player: Player = Thunder._current_player
@onready var bowser_portrait_left: Sprite2D = $"../BowserPortraitLeft"
@onready var bowser_portrait_right: Sprite2D = $"../BowserPortraitRight"

var _attacking: bool
var _tweaked_stomping_vel: float
var hud: CanvasLayer

var step: int
var step_1_timer: float
var step_2_counter: float
var step_5_dir: int = 0
var step_5_timer: float = 0
var portraits_active: bool


func _ready() -> void:
	super()
	if instakill_from_lava:
		$Body.add_to_group(&"#lava_body")
	sprite.animation_looped.connect(_on_sprite_animation_looped)
	_speed = speed.x
	facing = get_facing(facing)
	direction = facing
	vel_set_x(0)
	#enemy_attacked.killing_immune = {}
	#if tweaked_stomping:
	#	enemy_attacked.stomping_player_jumping_max = enemy_attacked.stomping_player_jumping_min
	
	# HUD
	hud = HUD.instantiate()
	hud.bowser = self
	hud.y_offset = y_offset
	health_changed.connect(hud.life_changed)
	add_sibling.call_deferred(hud)


func _physics_process(delta: float) -> void:
	# Direction
	if !lock_direction:
		facing = get_facing(facing)
		sprite.offset.x = 3 * facing
	
	# Animation
	if facing != 0:
		sprite.flip_h = (facing < 0)
	
	if !active: return
	
	if step == 0 && position.y >= 120:
		step = 1
		speed.y = 0
		lock_movement = false
	
	# Movement
	if !lock_movement:
		_movement(delta)
	elif speed.x != 0 && step != 4:
		_speed = abs(speed.x)
		vel_set_x(0)
	
	if Console.debug_mode:
		if Input.is_action_just_pressed(&"ui_page_down"):
			step = 3
			speed.y = -62.5 * 2.0
			tween_status = null
			$attack_shoot.end_attack()
			lock_movement = true
			step_1_timer = 0
	
	match step:
		1, 6:
			step_1_timer += delta
			if step_1_timer > 14.75 && step == 1:
				step = 2
				tween_status = null
				$attack_shoot.end_attack()
				lock_movement = true
				step_2_counter = 62.5 * 4.0
				speed.y = step_2_counter
				step_1_timer = 0
			
			# Attack
			elif !tween_status:
				tween_status = create_tween()
				for i in status.size():
					tween_status.tween_interval(status_interval[i])
					tween_status.tween_callback(attack.bind(status[i]))
				if _attacking:
					tween_status.pause()
				tween_status.finished.connect(func() -> void:
					tween_status = null
				)
		2:
			var pl: Player = Thunder._current_player
			if position.y > 548 && pl:
				speed.y = -step_2_counter
				position.y = 548
				position.x = pl.global_position.x
			
			if step_2_counter >= 531.25:
				step = 3
				speed.y = -62.5 * 2.0
		3:
			var pl: Player = Thunder._current_player
			if position.y < -100 && pl:
				var pl_pos: Vector2 = pl.position
				var moving_pos: Vector2 = Vector2(
					(640 - pl_pos.y) * (pl_pos.x - position.x) / (pl_pos.y - position.y) + pl_pos.x
				, 640)
				var dir = global_position.direction_to(moving_pos).angle()
				speed = Vector2(62.5 * 5.0, 0).rotated(dir)
				prints(moving_pos, dir, speed)
				position.y = -100
				step = 4
		4:
			var pl: Player = Thunder._current_player
			if position.y > 548 && pl:
				position.y = 548
				position.x = pl.global_position.x
				speed = Vector2.ZERO
				step = 5
				portraits_active = true
				Audio.play_1d_sound(LAUGHING, false)
				var tw = create_tween().set_parallel()
				tw.tween_property(bowser_portrait_left.get_child(0), "modulate:a", 1.0, 0.5)
				tw.tween_property(bowser_portrait_right.get_child(0), "modulate:a", 1.0, 0.5)
				bowser_portrait_left.get_node("Body/EnemyAttacked").stomping_enabled = true
				bowser_portrait_right.get_node("Body/EnemyAttacked").stomping_enabled = true
		5:
			step_5_timer += delta
			if step_5_timer > 3:
				speed.y = -62.5 * 2.0
				if position.y < -100 + 35:
					lock_movement = false
					speed.y = 0
					_speed = 156.25
					position.y = -100 + 35
					step = 6
	
	if portraits_active:
		if bowser_portrait_left.position.y < 288:
			bowser_portrait_left.position.y += delta * 93.75
			bowser_portrait_right.position.y += delta * 93.75
		else:
			if step_5_dir == 0:
				bowser_portrait_left.get_node("Body/EnemyAttacked").killing_enabled = true
				bowser_portrait_right.get_node("Body/EnemyAttacked").killing_enabled = true
				step_5_dir = 1
			bowser_portrait_right.position.x -= delta * 62.5 * step_5_dir
			bowser_portrait_left.position.x += delta * 62.5 * step_5_dir
			if bowser_portrait_left.position.x >= 1488 && step_5_dir == 1:
				step_5_dir = -1
			elif bowser_portrait_left.position.x <= 912 && step_5_dir == -1:
				step_5_dir = 1
	
	# Physics
	motion_process(delta)
	#if is_on_floor():
	#	pos_y_on_floor = global_transform.affine_inverse().basis_xform(global_position).y
	
	debug_text.visible = Console.cv.player_stats_shown
	
	# Old bowser stomping (Tweak)
	#if !tweaked_stomping || !_tweaked_stomping_vel: return
	if is_instance_valid(player) && !player.is_on_wall():
		player.position.x += _tweaked_stomping_vel * 50 * delta
	_tweaked_stomping_vel = move_toward(_tweaked_stomping_vel, 0.0, 50 * delta)


func activate() -> void:
	if active: return
	active = true
	direction = 1
	speed.x = _speed * direction
	_walking_move_distance = 64
	# Emit the signal
	health = health
	#enemy_attacked.killing_immune = initial_killing_immune.duplicate(true)
	player = Thunder._current_player
	speed.y = 62.5


# Bowser's attack
func attack(state: StringName) -> void:
	var _attack_node: BowserAttack = get_node_or_null("attack_" + state)
	assert(_attack_node && _attack_node is BowserAttack, "Please attach a BowserAttack node named attack_" + state + ".")
	if !_attack_node is BowserAttack:
		return
	
	tween_status.pause()
	_attacking = true
	_attack_node._accept_attack(self)


func _on_sprite_animation_looped() -> void:
	if sprite.animation in [&"jump", &"throw_pre"]:
		sprite.set_frame_and_progress(sprite.sprite_frames.get_frame_count(sprite.animation) - 1, 0.0)
	elif sprite.animation == &"flame_pre_multiple":
		sprite.set_frame_and_progress(sprite.sprite_frames.get_frame_count(sprite.animation) - 3, 0.0)


# Bowser's hurt
func hurt(_external_damage_source: bool = false) -> void:
	if tween_hurt: return
	enemy_attacked.killing_immune = {}
	
	#if !_external_damage_source && tweaked_stomping && is_instance_valid(player):
	#	_tweaked_stomping_vel = 8 * player.direction
	
	_bullet_received = 0
	if health > 0:
		var _sfx = CharacterManager.get_sound_replace(hurt_sound, hurt_sound, "bowser_hurt", false)
		Audio.play_sound(_sfx, self)
		health -= 1
		Thunder.autosplitter.update_il_counter()
	if health <= 0:
		die()
		return
	
	var stomp_standard: Vector2 = enemy_attacked.stomping_standard
	
	tween_hurt = create_tween()
	tween_hurt.tween_callback(
		func() -> void:
			enemy_attacked.stomping_standard = Vector2.ZERO
	)
	tween_hurt.tween_interval(invincible_duration)
	
	#if tween_hurt_blinking:
	#	tween_hurt_blinking.stop()
	sprite.modulate.a = 1.0
	#tween_hurt_blinking = create_tween()
	
	tween_hurt.finished.connect(func() -> void:
		tween_hurt.kill()
		tween_hurt = null
		sprite.modulate.a = 1.0
		enemy_attacked.stomping_standard = stomp_standard
		enemy_attacked.killing_immune = initial_killing_immune.duplicate(true)
	, CONNECT_ONE_SHOT)

# Hurt from bullets
func bullet_hurt(attacker: StringName) -> void:
	if tween_hurt: return
	
	if attacker == &"beetroot":
		_bullet_received += 1
	_bullet_received += 1
	if _bullet_received >= hardness || attacker == &"head":
		_bullet_received = 0
		hurt(true)

# Hurt from paintings
func painting_hurt(attacker: StringName) -> void:
	if tween_hurt: return
	
	if attacker == &"beetroot":
		_bullet_received += 0.5
	_bullet_received += 0.5
	if _bullet_received >= hardness:
		_bullet_received = 0
		hurt(true)


# Bowser's death
func die(corpse_intro: bool = true) -> void:
	print("[Game] Boss defeated.")
	Thunder.autosplitter.update_il_counter()
	var _sfx = CharacterManager.get_sound_replace(death_sound, death_sound, "bowser_be_happy", false)
	Audio.play_sound(_sfx, self)
	tween_hurt_blinking = null
	if health > 0: health = 0
	
	bowser_portrait_left.get_node("Body/EnemyAttacked").stomping_enabled = false
	bowser_portrait_left.get_node("Body/EnemyAttacked").killing_enabled = false
	bowser_portrait_right.get_node("Body/EnemyAttacked").stomping_enabled = false
	bowser_portrait_right.get_node("Body/EnemyAttacked").killing_enabled = false
	var tw = bowser_portrait_left.create_tween().set_parallel()
	tw.tween_property(bowser_portrait_left.get_child(0), "modulate:a", 0.0, 0.5)
	tw.tween_property(bowser_portrait_right.get_child(0), "modulate:a", 0.0, 0.5)
	
	if finish_on_death && trigger && trigger.has_method(&"stop_music"):
		if Thunder.autosplitter.can_split_on("boss_defeat"):
			Thunder.autosplitter.split("Boss Defeat")
		Scenes.current_scene.set_meta(&"boss_got_defeated", true)
		trigger.stop_music()
	
	NodeCreator.prepare_2d(CORPSE, self).bind_global_transform().call_method(
		func(cps: Node2D) -> void:
			if !corpse_intro:
				cps.duration = -1
	).create_2d().call_method(
		func(cps: Node2D) -> void:
			var spr: AnimatedSprite2D = sprite.duplicate()
			cps.add_child(spr)
			var spr2: Sprite2D = $BaseSprite.duplicate()
			cps.add_child(spr2)
			spr2.get_node("Skull").animation = "default"
			spr.modulate.a = 1.0
			spr.speed_scale = 1
			spr.play.call_deferred(&"death")
			if portraits_active:
				bowser_portrait_left.follow = cps
				bowser_portrait_right.follow = cps
			cps.add_child.call_deferred(collision_shape.duplicate())
			var _sfx2 = CharacterManager.get_sound_replace(falling_sound, falling_sound, "bowser_fall", false)
			cps.falling_sound = _sfx2
			_sfx2 = CharacterManager.get_sound_replace(into_lava_sound, into_lava_sound, "bowser_lava_love", false)
			cps.into_lava_sound = _sfx2
			cps.direction_to_complete = complete_direction
			cps.finish_on_free = finish_on_death
	)
	queue_free()


# Gets the facing of the bowser
func get_facing(dir: int) -> int:
	if !player: return dir
	return Thunder.Math.look_at(global_position, player.global_position, global_transform)


# Bowser's movement
func _movement(delta: float) -> void:
	# Update the random pausing every second
	if _walking_counter < 1.0:
		_walking_counter += delta
	else:
	# Setting random distance to walk
		_walking_move_distance = 64
		_walking_counter = 0.0
	
	if _walking_move_distance > 0.0:
		vel_set_x(_speed * direction)
		_walking_move_distance -= delta * 50
	# Pausing
	else:
		vel_set_x(0)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body == self: return
	if step != 2: return
	step_2_counter += 56.25
	speed.y = step_2_counter
