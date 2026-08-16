extends BowserAttack

@export var dash_sound: AudioStream = preload("res://objects/human_lab_2/zorro/sfx/swoosh.ogg")
@export var dash_distance: float = 200.0
@export var dash_duration: float = 0.6
@export var arena_center_offset := Vector2(-144, 0)
@export_group("Animations")
@export var animation_pre: String = "dash"
@export var animation_dash: String = "dash_on"
@export var animation_after: String = "flame_on"

@onready var collision_dash: CollisionShape2D = $"../Body/CollisionDash"
@onready var active_nogi: AnimatedSprite2D = $"../Sprite/ActiveNOGI"
@onready var arena_center_pos: Vector2 = $"..".position + arena_center_offset

var _dashing: bool


func start_attack() -> void:
	super()
	if !is_enough_space():
		end_attack()
		return
	
	bowser.lock_direction = true
	bowser.lock_movement = true
	bowser.jump_enabled = false
	bowser.speed.x = 0
	bowser.sprite.play(animation_pre)
	bowser.vel_set_x(bowser._speed * bowser.direction)
	if !bowser.sprite.animation_finished.is_connected(_on_windup_finished):
		bowser.sprite.animation_finished.connect(_on_windup_finished)


func _on_windup_finished() -> void:
	if !is_instance_valid(bowser) || bowser.health <= 0:
		return
	if bowser.sprite.animation != animation_pre:
		return
	middle_attack()


func _physics_process(_delta: float) -> void:
	if !_dashing || !is_instance_valid(bowser) || bowser.health <= 0:
		return
	if Engine.get_physics_frames() % 2 != 0:
		return
	bowser.sprite.play(animation_dash)
	var tra = Effect.trail(
		bowser, bowser.sprite.sprite_frames.get_frame_texture(animation_dash, 0),
		bowser.sprite.offset, bowser.sprite.flip_h, bowser.sprite.flip_v
	)
	Effect.trail(
		tra, active_nogi.sprite_frames.get_frame_texture(active_nogi.animation, active_nogi.frame),
		active_nogi.position, active_nogi.flip_h, active_nogi.flip_v
	)
	Thunder.reorder_on_top_of(bowser, tra)


func middle_attack() -> void:
	super()
	if bowser.sprite.animation_finished.is_connected(_on_windup_finished):
		bowser.sprite.animation_finished.disconnect(_on_windup_finished)
	bowser.sprite.play(animation_dash)
	collision_dash.disabled = false
	_dashing = true
	Audio.play_sound(dash_sound, bowser, false)
	bowser.direction = bowser.get_facing(bowser.facing)
	var tw = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_trans(Tween.TRANS_SINE)
	tw.tween_property(bowser, "position:x", bowser.position.x + (dash_distance * bowser.facing), dash_duration).set_ease(Tween.EASE_OUT)
	tw.tween_callback(pre_end_attack)

func pre_end_attack() -> void:
	_dashing = false
	if is_instance_valid(collision_dash):
		collision_dash.disabled = true
	if bowser.sprite.animation_finished.is_connected(_on_windup_finished):
		bowser.sprite.animation_finished.disconnect(_on_windup_finished)
	if is_instance_valid(bowser):
		bowser.lock_direction = false
		bowser.lock_movement = false
		bowser.jump_enabled = true
		bowser.sprite.play(animation_after)
		bowser.vel_set_x(bowser._speed * bowser.direction)
	end_attack()


func is_enough_space() -> bool:
	return (
		bowser.position.x <= arena_center_pos.x && bowser.facing == 1
	) || (
		bowser.facing == -1 && bowser.position.x >= arena_center_pos.x
	)
