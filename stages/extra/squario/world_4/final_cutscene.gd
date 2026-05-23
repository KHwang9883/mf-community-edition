extends Node

const EXPLOSION_TANK = preload("res://stages/cutscenes/ending/part_1/scripts/explosion_tank.tscn")
const JEBUT = preload("uid://2wvrmeop3e7w")

var spr_dict: Dictionary[Texture2D, Rect2i] = {
	preload("res://engine/objects/enemies/buzzle_bettle/textures/buzzle_beetle.png"):
		Rect2i(0,0,31,32),
	preload("res://engine/objects/enemies/goombas/textures/goomba.png"):
		Rect2i(0,0,31,32),
	preload("res://engine/objects/enemies/koopas/textures/koopa_green.png"):
		Rect2i(32,0,32,48),
	preload("res://engine/objects/enemies/koopas/textures/koopa_red.png"):
		Rect2i(32,0,32,48),
	preload("res://engine/objects/enemies/spinies/textures/spiny_red.png"):
		Rect2i(0,32,32,32),
	preload("res://engine/objects/enemies/spinies/textures/spiny_egg_red.png"):
		Rect2i(0,0,31,31),
	preload("res://engine/objects/enemies/lakitus/textures/lakitu.png"):
		Rect2i(0,0,31,48),
	preload("res://engine/objects/enemies/bullet_bill/bill/textures/bullet_bill.png"):
		Rect2i(0,0,34,28),
	preload("res://engine/objects/enemies/podoboo/podoboo.png"):
		Rect2i(32,0,32,32),
	preload("res://engine/objects/enemies/koopas/textures/shell_green.png"):
		Rect2i(32,0,32,28),
	preload("res://engine/objects/enemies/koopas/textures/shell_red.png"):
		Rect2i(32,0,32,28),
	preload("res://engine/objects/projectiles/hammer/texture.png"):
		Rect2i(0,0,24,33),
	preload("res://engine/objects/enemies/hammer_bros/textures/green_bro.png"):
		Rect2i(0,0,33,48),
	preload("res://engine/objects/enemies/piranha_plants/textures/head_green.png"):
		Rect2i(32,0,32,32),
}

@export_multiline var credits_text: PackedStringArray

@onready var player: Player = Thunder._current_player
@onready var castle = $"../Castle"
@onready var castle_end_marker = $"../CastleEndMarker"
@onready var castle_pos: float = castle.position.x
@onready var color_rect: ColorRect = $"../CanvasLayer/ColorRect"
@onready var logo_2: Sprite2D = $"../CanvasLayer/Logo2"
@onready var control: Control = $"../CanvasLayer/Control"
@onready var label: Label = $"../CanvasLayer/Control/Label"
@onready var sprite_holder: Node2D = $"../SpriteHolder"

var _flashed: bool
var _destroying: bool = false
var _castle_speed: float = -5
var _label_index: int = 0
var sprites: Array[Sprite2D]
var skippable: bool

func _ready() -> void:
	control.modulate.a = 0.0
	label.modulate.a = 0.0
	
	await get_parent().ready
	player = Thunder._current_player
	player.completed = true
	player.change_suit(CharacterManager.get_suit("super"), false, true)
	run_while(_smoke_particles, 0.02)
	run_while(_enemy_particles, 0.05, false)
	
	await get_tree().create_timer(2.0, false).timeout
	_destroying = true
	
	#await get_tree().create_timer(0.5, false).timeout
	#_moving = true
	
	#Audio.play_1d_sound(CASTLE_CRASH)
	#Thunder._current_camera.shock(2, Vector2(4, 4))
	
	
	#run_while(func():
	#	castle.position.x = castle_pos + randi_range(-3, 3), 0.01
	#)
	#run_while(_brick_particles, 0.15)


func _physics_process(delta: float) -> void:
	if skippable:
		if Input.is_action_pressed(&"m_jump") || Input.is_action_pressed(&"ui_accept"):
			Scenes.current_scene.end()
			skippable = false
	else:
		castle.position.x = castle_pos + randi_range(-5, 5)
	
	if _destroying:
		_castle_speed += delta * 50
		castle.position.y += delta * _castle_speed
	for i in sprites:
		if !is_instance_valid(i): continue
		var spd: Vector2 = i.get_meta(&"speed", Vector2.DOWN)
		i.position += spd * 50 * delta
		i.rotation += spd.x * 5 * delta
		i.set_meta(&"speed", spd + Vector2(0, 20) * delta)
		if i.position.y > 500:
			i.queue_free()
	if _flashed:
		return
	if castle.position.y > 352:
		_flash()
	


func _flash() -> void:
	_flashed = true
	Audio.play_1d_sound(JEBUT)
	var tw = create_tween()
	tw.tween_property(color_rect, "modulate:a", 1.0, 0.25)
	tw.tween_callback(func():
		for i in sprites:
			if is_instance_valid(i):
				i.queue_free()
		sprites = []
	)
	tw.tween_interval(2.0)
	tw.tween_callback(logo_2.show)
	tw.tween_property(color_rect, "modulate:a", 0.0, 2.0)
	tw.tween_interval(1.0)
	tw.tween_property(control, "modulate:a", 1.0, 1.5)
	tw.tween_callback(text_tw)

func text_tw() -> void:
	label.modulate.a = 0.0
	var tw = create_tween().set_loops(len(credits_text))
	tw.tween_property(label, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func():
		label.text = credits_text[_label_index]
		_label_index += 1
		if _label_index == len(credits_text) - 1:
			label.add_theme_font_size_override(&"font_size", 32)
		elif _label_index == len(credits_text):
			skippable = true
			label.remove_theme_font_size_override(&"font_size")
	)
	tw.tween_property(label, "modulate:a", 1.0, 0.2)
	tw.tween_interval(8.0 * Engine.time_scale)


func run_while(callable: Callable, repeat_delay: float, twice: bool = true) -> void:
	if _flashed: return
	callable.call()
	if twice:
		callable.call()
	await get_tree().create_timer(repeat_delay, false, false, true).timeout
	run_while(callable, repeat_delay)


#func _brick_particles() -> void:
	#var brick = CASTLE_BRICK.instantiate()
	#brick.position = castle_end_marker.position + Vector2(randi_range(-145, 145), 16)
	#brick.reset_physics_interpolation()
	#brick.speed = Vector2(randf_range(-4.0, 4.0), randi_range(-11, -6))
	#Scenes.current_scene.add_child(brick)

func _enemy_particles() -> void:
	var d = randi_range(0, spr_dict.keys().size() - 1)
	
	var spr = Sprite2D.new()
	spr.texture = spr_dict.keys()[d]
	spr.region_enabled = true
	spr.region_rect = spr_dict.values()[d]
	var spdx = randi_range(-3, 3)
	spr.set_meta(&"speed", Vector2(spdx, randi_range(-4, -7)))
	if spdx == 0:
		spr.flip_v = true
	var randx = randi_range(-128, 128)
	spr.position = Vector2(randx, castle.position.y + 176)
	if abs(randx) < 48:
		spr.position.y -= 96
	sprites.append(spr)
	sprite_holder.add_child(spr)


func _smoke_particles() -> void:
	var smoke = EXPLOSION_TANK.instantiate()
	smoke.position = castle_end_marker.position + Vector2(randi_range(-157, 157), 16)
	smoke.reset_physics_interpolation()
	Scenes.current_scene.add_child(smoke)
