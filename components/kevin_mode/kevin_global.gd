extends Node

var activated: bool = false
var _current_kevin: Area2D

func _ready() -> void:
	Scenes.scene_ready.connect(add_kevin)
	Scenes.scene_ready.connect(patch_mario)

func add_kevin() -> void:
	await get_tree().physics_frame
	if !activated || Scenes.current_scene.name == 'SaveGameRoom': return
	var kevin = preload("res://objects/chorniy_mario/chorniy_mario.tscn").instantiate()
	kevin.global_position = Vector2(-100, -100)
	_current_kevin = kevin
	Scenes.current_scene.add_child(kevin)

func patch_mario() -> void:
	if Scenes.current_scene.name == "SaveGameRoom": return
	if is_instance_valid(Thunder._current_player) && activated:
		Thunder._current_player.death_check_for_lives = false
