extends Node

const KEVIN_SCENE = preload("res://objects/chorniy_mario/chorniy_mario.tscn")

var activated: bool = false
var _current_kevin: Area2D
var wait_time: float

func _ready() -> void:
	Scenes.scene_ready.connect(add_kevin)
	Scenes.scene_ready.connect(patch_mario)

func add_kevin() -> void:
	if !OS.has_feature("template") && Input.is_action_pressed("a_delete"):
		activated = true
	if !activated || Scenes.current_scene.name == 'SaveGameRoom': return
	var kevin := KEVIN_SCENE.instantiate()
	kevin.position = Vector2(-100, -100)
	_current_kevin = kevin
	Scenes.current_scene.add_child(kevin)

func patch_mario() -> void:
	if !OS.has_feature("template") && Input.is_action_pressed("a_delete"):
		activated = true
	if Scenes.current_scene.name == "SaveGameRoom": return
	if is_instance_valid(Thunder._current_player) && activated:
		Thunder._current_player.death_check_for_lives = false
		Thunder._current_player.death_wait_time = 9999999
		Thunder._current_player.died.connect(loludied)

func loludied() -> void:
	Data.values.lives -= 1
	Scenes.custom_scenes.pause.open_blocked = true
	Loludied.get_child(0).activate(wait_time)
