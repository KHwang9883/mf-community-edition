extends Node

const KEVIN_SCENE = preload("res://objects/chorniy_mario/chorniy_mario.tscn")

signal touched_kevin

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
	var fast_respawn: bool = SettingsManager.get_tweak("fast_respawn", false)
	var player: Player = Thunder._current_player
	
	if player && activated:
		player.death_check_for_lives = false
		if player.death_stop_music && !fast_respawn:
			player.death_wait_time = 9999999
			player.died.connect(loludied)

func loludied() -> void:
	Data.values.lives -= 1
	Scenes.custom_scenes.pause.open_blocked = true
	Loludied.get_child(0).activate(wait_time)
