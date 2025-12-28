extends Node

const CASTLE_SMOKE = preload("res://engine/scenes/castle_cutscene/objects/castle_smoke.tscn")
const JEBUT = preload("uid://2wvrmeop3e7w")

@export_multiline var credits_text: PackedStringArray

@onready var player: Player = Thunder._current_player
@onready var castle = $"../Castle"
@onready var castle_end_marker = $"../CastleEndMarker"
@onready var castle_pos: float = castle.position.x
@onready var color_rect: ColorRect = $"../CanvasLayer/ColorRect"
@onready var logo_2: Sprite2D = $"../CanvasLayer/Logo2"
@onready var control: Control = $"../CanvasLayer/Control"
@onready var label: Label = $"../CanvasLayer/Control/Label"

var _flashed: bool
var _destroying: bool = false
var _castle_speed: float = 5
var _label_index: int = 0

func _ready() -> void:
	control.modulate.a = 0.0
	label.modulate.a = 0.0
	
	await get_parent().ready
	player = Thunder._current_player
	player.completed = true
	player.change_suit(CharacterManager.get_suit("super"), false, true)
	run_while(_smoke_particles, 0.02)
	
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
	castle.position.x = castle_pos + randi_range(-5, 5)
	
	if _destroying:
		_castle_speed += delta * 50
		castle.position.y -= delta * _castle_speed
	if _flashed:
		return
	if castle.position.y < -352:
		_flash()

func _flash() -> void:
	_flashed = true
	Audio.play_1d_sound(JEBUT)
	var tw = create_tween()
	tw.tween_property(color_rect, "modulate:a", 1.0, 0.25)
	tw.tween_interval(1.0)
	tw.tween_callback(logo_2.show)
	tw.tween_property(color_rect, "modulate:a", 0.0, 2.0)
	tw.tween_interval(1.0)
	tw.tween_property(control, "modulate:a", 1.0, 1.5)
	tw.tween_callback(text_tw)

func text_tw() -> void:
	var tw = create_tween().set_loops(len(credits_text))
	tw.tween_callback(func():
		label.text = credits_text[_label_index]
		_label_index += 1
		if _label_index == len(credits_text):
			label.add_theme_font_size_override(&"font_size", 32)
	)
	tw.tween_property(label, "modulate:a", 1.0, 0.2)
	tw.tween_interval(5.0)
	tw.tween_property(label, "modulate:a", 0.0, 0.2)
	await tw.finished
	Scenes.current_scene.end()

func run_while(callable: Callable, repeat_delay: float) -> void:
	if _flashed: return
	callable.call()
	callable.call()
	await get_tree().create_timer(repeat_delay, false, false, true).timeout
	run_while(callable, repeat_delay)


#func _brick_particles() -> void:
	#var brick = CASTLE_BRICK.instantiate()
	#brick.position = castle_end_marker.position + Vector2(randi_range(-145, 145), 16)
	#brick.reset_physics_interpolation()
	#brick.speed = Vector2(randf_range(-4.0, 4.0), randi_range(-11, -6))
	#Scenes.current_scene.add_child(brick)


func _smoke_particles() -> void:
	var smoke = CASTLE_SMOKE.instantiate()
	smoke.position = castle_end_marker.position + Vector2(randi_range(-144, 144), castle.position.y)
	smoke.reset_physics_interpolation()
	smoke.y_modifier = -20
	smoke.y_modify_over_time = 0.4
	smoke.apply_force_below_y = 352
	smoke.rotation_speed = randi_range(-180, 180)
	smoke.z_index = 0
	Scenes.current_scene.add_child(smoke)
