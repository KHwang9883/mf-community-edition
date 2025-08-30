extends "res://engine/objects/bosses/bowser/bowser.gd"

const LAUGHING = preload("res://engine/objects/enemies/thwomp/sounds/laughing.wav")
const BREAK = preload("res://engine/objects/bumping_blocks/_sounds/break.wav")
const DAMAGED_TILE = preload("res://stages/extra/expert_mode/ending_scene/breakage/damaged_tile.tscn")
const BOWSER_HUD = preload("res://stages/extra/expert_mode/objects/expert_bowser_hud.tscn")

var second_phase: bool
@onready var static_body_2d: StaticBody2D = $"../TileMapLayer/StaticBody2D"
@onready var static_body_2d_2: StaticBody2D = $"../TileMapLayer/StaticBody2D2"
@onready var static_body_2d_3: StaticBody2D = $"../TileMapLayer/StaticBody2D3"
@onready var static_body_2d_4: StaticBody2D = $"../TileMapLayer/StaticBody2D4"
@onready var thwomp: CharacterBody2D = $"../Thwomp"
@onready var thwomp2: CharacterBody2D = $"../Thwomp2"

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
	hud = BOWSER_HUD.instantiate()
	hud.bowser = self
	hud.y_offset = y_offset
	health_changed.connect(hud.life_changed)
	add_sibling.call_deferred(hud)
	
	Thunder._connect(health_changed, _on_health_changed)

func _on_health_changed(to: int) -> void:
	if to > 10:
		return
	if to == 0:
		if is_instance_valid(thwomp):
			thwomp.trigger_area.size.y = 1
			thwomp._origin = Vector2(96, -80)
			thwomp._stunspot = thwomp.global_position
			thwomp._step = 3
		if is_instance_valid(thwomp2):
			thwomp2.trigger_area.size.y = 1
			thwomp2._origin = Vector2(544, -80)
			thwomp2._stunspot = thwomp2.global_position
			thwomp2._step = 3
		var platf: Node2D = get_node_or_null("../AmazingPlatf")
		if is_instance_valid(platf):
			if platf.position.y < 500:
				var tw: Tween = platf.create_tween()
				tw.tween_property(platf, "modulate:a", 0.0, 0.8)
				tw.tween_callback(func():
					platf.get_node("Body1").set_deferred(&"collision_layer", 0)
					platf.get_node("Body2").set_deferred(&"collision_layer", 0)
				)
	
	if second_phase: return
	second_phase = true
	if !is_instance_valid(thwomp) || !is_instance_valid(thwomp2):
		return
	$attack_platfstart.burst_attack_offset_from_screen_border = 164
	await get_tree().create_timer(0.6, false).timeout
	Audio.play_1d_sound(LAUGHING, false)
	await get_tree().create_timer(2.0, false).timeout
	if !is_instance_valid(thwomp) || !is_instance_valid(thwomp2):
		return
	static_body_2d.get_child(0).set_deferred(&"disabled", true)
	static_body_2d_2.get_child(0).set_deferred(&"disabled", true)
	thwomp._origin = thwomp.global_position
	thwomp._step = 1
	thwomp2._origin = thwomp2.global_position
	thwomp2._step = 1
	await thwomp.stun
	var _break = CharacterManager.get_sound_replace(BREAK, BREAK, "block_break", false)
	Audio.play_1d_sound(_break, false)
	_create_tile(Vector2(80, 16), -1)
	_create_tile(Vector2(112, 16))
	_create_tile(Vector2(528, 16), -1)
	_create_tile(Vector2(560, 16))
	static_body_2d.queue_free()
	static_body_2d_2.queue_free()
	await get_tree().create_timer(2.0, false).timeout
	if !is_instance_valid(thwomp) || !is_instance_valid(thwomp2):
		return
	static_body_2d_3.get_child(0).set_deferred(&"disabled", true)
	static_body_2d_4.get_child(0).set_deferred(&"disabled", true)
	thwomp._origin = thwomp.global_position
	thwomp._step = 1
	thwomp2._origin = thwomp2.global_position
	thwomp2._step = 1
	while is_instance_valid(thwomp) && thwomp.global_position.y < 24:
		if !is_inside_tree(): return
		await get_tree().physics_frame
		
	if !is_instance_valid(thwomp) || !is_instance_valid(thwomp2):
		return
	thwomp._origin = Vector2(96, 32)
	thwomp.trigger_area.size.y = 500
	thwomp2._origin = Vector2(544, 32)
	thwomp2.trigger_area.size.y = 500
	Audio.play_1d_sound(_break, false)
	_create_tile(Vector2(80, 48), -1)
	_create_tile(Vector2(112, 48))
	_create_tile(Vector2(528, 48), -1)
	_create_tile(Vector2(560, 48))
	static_body_2d_3.queue_free()
	static_body_2d_4.queue_free()
	

func _create_tile(at: Vector2, dir: int = 1) -> void:
	var tile = DAMAGED_TILE.instantiate()
	Scenes.current_scene.add_child(tile)
	tile.position = at
	tile.speed = Vector2(randf_range(1, 2) * dir, randf_range(-2, -3))
	tile.reset_physics_interpolation()


func _physics_process(delta: float) -> void:
	# Direction
	if !lock_direction:
		facing = get_facing(facing)
		if sprite.animation == &"throw":
			sprite.offset.x = 7 * facing
			sprite.reset_physics_interpolation()
	
	# Animation
	if facing != 0:
		sprite.flip_h = (facing < 0)
	
	if !active: return
	if is_on_floor() && sprite.animation == &"jump" || !sprite.is_playing():
		sprite.play(&"default")
	if sprite.animation == &"default" && !is_on_floor():
		sprite.play(&"jump")
	
	# Pos markers
	#pos_flame.position.x = pos_flame_x * facing
	#pos_hammer.position.x = pos_hammer_x * facing
	
	# Movement
	if !lock_movement:
		_movement(delta)
	elif abs(speed.x) > 60:
		_speed = abs(speed.x)
		vel_set_x(0)
	
	# Jump
	if jump_enabled:
		_jumping(delta)
	
	# Attack
	if !tween_status:
		tween_status = create_tween()
		for i in status.size():
			tween_status.tween_interval(status_interval[i])
			tween_status.tween_callback(attack.bind(status[i]))
		if _attacking:
			tween_status.pause()
		tween_status.finished.connect(func() -> void:
			tween_status = null
		)
	else:
		debug_text.text = debug_text_template % [
			tween_status.get_total_elapsed_time(), tween_status.is_running(),
			tween_status.get_loops_left(), _speed, velocity
		]
	
	# Physics
	motion_process(delta)
	if is_on_floor():
		pos_y_on_floor = 320 #global_transform.affine_inverse().basis_xform(global_position).y
	
	debug_text.visible = Console.cv.player_stats_shown
	if OS.is_debug_build() && Input.is_action_just_pressed(&"a_delete"):
		health = 11
	
	# Old bowser stomping (Tweak)
	if !tweaked_stomping || !_tweaked_stomping_vel: return
	if is_instance_valid(player) && !player.is_on_wall():
		player.position.x += _tweaked_stomping_vel * 50 * delta
	_tweaked_stomping_vel = move_toward(_tweaked_stomping_vel, 0.0, 50 * delta)
