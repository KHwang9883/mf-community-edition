extends Node

const KEVIN_SCENE = preload("res://objects/chorniy_mario/chorniy_mario.tscn")

var activated: bool = false
var _current_kevin: Area2D

func _ready() -> void:
	Scenes.scene_ready.connect(add_kevin)
	Scenes.scene_ready.connect(patch_mario)

func add_kevin() -> void:
	await get_tree().physics_frame
	if !activated || Scenes.current_scene.name == 'SaveGameRoom': return
	var kevin := KEVIN_SCENE.instantiate()
	kevin.position = Vector2(-100, -100)
	_current_kevin = kevin
	Scenes.current_scene.add_child(kevin)

func patch_mario() -> void:
	if Scenes.current_scene.name == "SaveGameRoom": return
	if is_instance_valid(Thunder._current_player) && activated:
		Thunder._current_player.death_check_for_lives = false
		Thunder._current_player.death_wait_time = 9999999
		Thunder._current_player.died_with_body.connect(func(body):
			body.process_mode = Node.PROCESS_MODE_INHERIT
		)
