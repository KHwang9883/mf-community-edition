extends "res://engine/objects/bosses/bowser/bowser.gd"

const SWOOSH = preload("res://objects/human_lab_2/zorro/sfx/swoosh.ogg")

const ZORRO_HUD = preload("res://objects/human_lab_2/zorro/zorro_hud.tscn")
@onready var collision_dash: CollisionShape2D = $Body/CollisionDash
@onready var collision_dash_x_pos: float = collision_dash.position.x
@onready var active_nogi: AnimatedSprite2D = $Sprite/ActiveNOGI

var after_attack_delay: float
var prev_attacking: bool
var dashing: bool
@onready var arena_center_pos: Vector2 = position + Vector2(-144, 0)

func _ready() -> void:
	if instakill_from_lava:
		$Body.add_to_group(&"#lava_body")
	sprite.animation_looped.connect(_on_sprite_animation_looped)
	_speed = speed.x
	facing = get_facing(facing)
	direction = facing
	vel_set_x(0)
	#enemy_attacked.killing_immune = {}
	if tweaked_stomping:
		enemy_attacked.stomping_player_jumping_max = enemy_attacked.stomping_player_jumping_min
	
	# HUD
	hud = ZORRO_HUD.instantiate()
	hud.bowser = self
	hud.y_offset = y_offset
	health_changed.connect(hud.life_changed)
	add_sibling.call_deferred(hud)


func _physics_process(delta: float) -> void:
	super(delta)
	sprite.offset.x = 10 * facing
	if !active: return
	if prev_attacking != _attacking:
		after_attack_delay = 0.01 if !_attacking else 0.0
		prev_attacking = _attacking
	
	if after_attack_delay > 0.0:
		after_attack_delay += delta
		if !_attacking && after_attack_delay > 1.0 && is_enough_space():
			after_attack_delay = 0.0
			_attacking = true
			lock_direction = true
			lock_movement = true
			jump_enabled = false
			speed.x = 0
			sprite.play(&"dash")
			vel_set_x(_speed * direction)
	
	if dashing && Engine.get_physics_frames() % 2 == 0 && health > 0:
		sprite.play(&"dash_on")
		var tra = Effect.trail(
			self, sprite.sprite_frames.get_frame_texture(&"dash_on", 0),
			sprite.offset, sprite.flip_h, sprite.flip_v
		)
		Effect.trail(
			tra, active_nogi.sprite_frames.get_frame_texture(active_nogi.animation, active_nogi.frame),
			active_nogi.position, active_nogi.flip_h, active_nogi.flip_v
		)
		Thunder.reorder_on_top_of(self, tra)
	collision_dash.position.x = collision_dash_x_pos * facing

# Bowser's death
func die(corpse_intro: bool = true) -> void:
	active_nogi.free()
	super(corpse_intro)


func _on_sprite_animation_finished() -> void:
	if health <= 0:
		return
	if sprite.animation == &"dash":
		sprite.play(&"dash_on")
		collision_dash.disabled = false
		dashing = true
		Audio.play_sound(SWOOSH, self, false)
		direction = get_facing(facing)
		var tw = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_trans(Tween.TRANS_SINE)
		tw.tween_property(self, "position:x", position.x + (200 * facing), 0.6).set_ease(Tween.EASE_OUT)
		await tw.finished
		dashing = false
		collision_dash.disabled = true
		_attacking = false
		lock_direction = false
		lock_movement = false
		jump_enabled = true
		sprite.play(&"flame_on")
		vel_set_x(_speed * direction)


func is_enough_space() -> bool:
	return (
		position.x <= arena_center_pos.x && facing == 1
	) || (
		facing == -1 && position.x >= arena_center_pos.x
	)
