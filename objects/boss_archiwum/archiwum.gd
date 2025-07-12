extends GeneralMovementBody2D

signal attack_complete
signal deactivation_complete

@export var lives: int = 5

var rng = RandomNumberGenerator.new()

var inactive: bool = true
var movement_active: bool = false
var deactivating: bool = false
var general_counter: float
var can_move: bool = false

var fireball_lives: int = 0
var invis_c: float = 0
var modul_switch: bool = false
var dead: bool = false
var dead_counter: float = 50
var dead_pos: Vector2

var initial_pos: Vector2

var activate_sound = preload("res://objects/boss_archiwum/sounds/activate.ogg")
var kick_sound = preload("res://engine/objects/players/prefabs/sounds/kick.wav")
var hurt_sound = preload("res://objects/boss_archiwum/sounds/dust_hurt.wav")
var bump_sound = preload("res://engine/objects/bumping_blocks/_sounds/bump.wav")
var explode_sound = preload("res://objects/boss_archiwum/sounds/boss_explode.wav")

var explosion_effect = preload("res://engine/objects/effects/explosion/explosion.tscn")

@onready var enemy_attacked: Node = $Body/EnemyAttacked

func _ready() -> void:
	initial_pos = global_position


func activate() -> void:
	Audio.play_sound(activate_sound, self)
	inactive = false
	get_node(sprite).play_backwards("closing")
	enemy_attacked.stomping_hurtable = true
	
	await get_tree().create_timer(0.7, false).timeout
	movement_active = true


func deactivate() -> void:
	deactivating = true
	inactive = true
	movement_active = false
	rotation_degrees = 0
	speed = Vector2.ZERO
	enemy_attacked.stomping_hurtable = false
	await deactivation_complete
	get_node(sprite).play("closing")
	attack_complete.emit()


func _physics_process(delta: float) -> void:
	if dead:
		_process_dead(delta)
		return
		
	if !inactive: super(delta)
	
	if deactivating:
		global_position = lerp(global_position, initial_pos, 0.3 * Thunder.get_delta(delta))
		if is_equal_approx(int(global_position.x / 4), int(initial_pos.x / 4)) && is_equal_approx(int(global_position.y / 4), int(initial_pos.y / 4)):
			deactivation_complete.emit()
			deactivating = false
			global_position = initial_pos
	
	var asprite = get_node(sprite)
	
	if invis_c > 0:
		invis_c -= 1 * Thunder.get_delta(delta)
		
		asprite.modulate.a += (-0.04 if !modul_switch else 0.04) * Thunder.get_delta(delta)
		if !modul_switch && asprite.modulate.a <= 0.25:
			modul_switch = true
		if modul_switch && asprite.modulate.a >= 1:
			modul_switch = false
	else:
		asprite.modulate.a = 1


func _process_dead(_delta: float) -> void:
	var delta = Thunder.get_delta(_delta)
	
	dead_counter -= delta
	
	global_position = dead_pos + Vector2(rng.randi_range(-2, 2), rng.randi_range(-2, 2))
	
	if int(dead_counter) % 15 == 0 && dead_counter > 1:
		Audio.play_sound(explode_sound, self)
		
		NodeCreator.prepare_2d(explosion_effect, self).create_2d().bind_global_transform().call_method(func(node: AnimatedSprite2D):
			node.global_position += Vector2(rng.randi_range(-20, 20), rng.randi_range(-16, 16))
		)
	
	if dead_counter <= 1 && dead_counter > -99:
		dead_counter = -99
		Audio.play_1d_sound(explode_sound)
		NodeCreator.prepare_2d(explosion_effect, self).create_2d().bind_global_transform().call_method(func(node: AnimatedSprite2D):
			node.scale *= 2
			node.speed_scale = 0.3
		)
		await get_tree().create_timer(0.5, false).timeout
		attack_complete.emit()
		queue_free()


func try_hurt() -> void:
	if invis_c > 0 || inactive:
		Audio.play_sound(bump_sound, self)
		return
	
	if fireball_lives < 5:
		Audio.play_sound(kick_sound, self)
		fireball_lives += 1
	else:
		lives -= 1
		if lives > 0:
			invis_c = 115
			fireball_lives = 0
		else:
			inactive = true
			dead = true
			dead_pos = global_position
