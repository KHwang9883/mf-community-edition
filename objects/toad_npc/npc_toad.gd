@tool
extends Sprite2D

@export var facing_player: bool = true
@export_range(-1, 1, 0.01) var hue: float
@export var initial_animation: StringName = "idle"

var dir: int

var _dir: int

@onready var animation: AnimationPlayer = $Animation


func _ready() -> void:
	if Engine.is_editor_hint(): return
	if initial_animation != "":
		animation.play(initial_animation)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		var animation_player: AnimationPlayer = $Animation
		if material is ShaderMaterial:
			material.set_shader_parameter(&"hue", hue)
		if animation_player.has_animation(initial_animation) && animation_player.current_animation != initial_animation:
			animation_player.play(initial_animation)
		return
	
	if !facing_player:
		return
	face_to_player()


func face_to_player(record_facing: bool = false) -> void:
	if record_facing:
		_dir = -1 if flip_h else 1
	var player: Player = Thunder._current_player
	if !player: return
	
	dir = Thunder.Math.look_at(global_position, player.global_position, global_transform)
	if dir != 0:
		flip_h = (dir < 0)


func recover_facing() -> void:
	if _dir != 0:
		dir = _dir
		flip_h = (dir < 0)


func forced_facing(to: int) -> void:
	if to != 0:
		dir = to
		flip_h = (dir < 0)


func play_animation(anim: String) -> void:
	if animation.has_animation(anim): animation.play(anim)
