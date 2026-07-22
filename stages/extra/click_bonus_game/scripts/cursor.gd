extends Node2D

const LAKITU_MYU = preload("res://engine/objects/enemies/lakitus/sounds/lakitu_myu.ogg")
const CURSOR_EFFECT = preload("res://stages/extra/click_bonus_game/objects/cursor_effect/cursor_effect.tscn")
const DIE = preload("res://stages/extra/click_bonus_game/sfx/die.wav")

var hover_count: int = 0

@onready var timer = $Timer
@onready var gpu_particles_2d = $CanvasLayer/Cursor/GPUParticles2D
@onready var gpu_particles_2d_2 = $CanvasLayer/Cursor/GPUParticles2D2
@onready var area_2d: Area2D = $Area2D
@onready var cursor: Sprite2D = $CanvasLayer/Cursor
@onready var canvas_layer: CanvasLayer = $CanvasLayer

@export var camera_ref: NodePath
@onready var camera: Camera2D = get_node(camera_ref)

var _saved_mouse_pos: Vector2


func _ready() -> void:
	timer.timeout.connect(_create_effect)


func _physics_process(_delta: float) -> void:
	area_2d.global_position = _saved_mouse_pos + camera.offset

func _process(delta: float) -> void:
	cursor.global_position = cursor.get_global_mouse_position()


func _input(event) -> void:
	if event is InputEventMouseMotion:
		_saved_mouse_pos = event.global_position
		area_2d.global_position = _saved_mouse_pos + camera.offset
		cursor.global_position = cursor.get_global_mouse_position()
	
	if !Scenes.current_scene.can_interact:
		return
	
	if event is InputEventMouseButton && event.button_index == 1 && event.is_pressed():
		var group_stars = get_tree().get_nodes_in_group(&"bonus_star")
		var hud_find_me_star = get_tree().get_first_node_in_group(&"find_me_star")
		var has_collision: bool
		var has_failed: bool = true
		for i in area_2d.get_overlapping_areas():
			if group_stars.has(i):
				has_collision = true
				i.activate()
				break
			if hud_find_me_star == i:
				has_failed = false
		if !has_collision:
			gpu_particles_2d.restart()
			Audio.play_1d_sound(DIE)
			if has_failed:
				Scenes.current_scene.tries._try_lost()
		else:
			gpu_particles_2d_2.restart()
			Audio.play_1d_sound(LAKITU_MYU)


func _create_effect() -> void:
	var eff = CURSOR_EFFECT.instantiate()
	eff.transform = cursor.transform
	canvas_layer.add_child(eff)


func add_hover() -> void:
	hover_count += 1


func remove_hover() -> void:
	hover_count -= 1
