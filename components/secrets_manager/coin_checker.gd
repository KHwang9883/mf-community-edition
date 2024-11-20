extends Node2D

signal coin_checked_success

@export_file("*.tscn", "*.scn") var toad_scene: String
@export var string_node_path: NodePath = ^"../HUD/ToadWarp"

@onready var string_node: Node = get_node_or_null(string_node_path)
var sound_effect_played: bool

func _ready() -> void:
	if !SettingsManager.get_tweak("minigames_in_main_worlds", true):
		return
	Scenes.current_scene.level_completed.connect(check_for_coins, CONNECT_DEFERRED)
	await get_tree().physics_frame
	child_exiting_tree.connect(_on_child_exiting_tree.unbind(1), CONNECT_DEFERRED)
	for i in get_children():
		if i.has_signal(&"bumped"):
			Thunder._connect(i.bumped, _on_child_exiting_tree, CONNECT_DEFERRED)


func _on_child_exiting_tree() -> void:
	if get_child_count() > 40 || sound_effect_played:
		return
	
	if _has_collected(true):
		Audio.play_1d_sound(preload("res://stages/extra/click_bonus_game/sfx/discoveredgunpowder-.wav"))
		sound_effect_played = true


func check_for_coins() -> void:
	if !_has_collected(true):
		return
	
	Data.technical_values.map_scene = Scenes.current_scene.jump_to_scene
	Scenes.current_scene.jump_to_scene = toad_scene
	Scenes.current_scene.completion_center_on_player_after_transition = true
	coin_checked_success.emit()
	
	if string_node:
		string_node.activate()


func _has_collected(ending: bool = false) -> bool:
	var is_debug: bool = !OS.has_feature("template") && ending
	for i in get_children():
		if i.is_in_group(&"coin"):
			if is_debug: print_debug("Coin Check Failed: " + i.name)
			return false
		if !&"result_counter_value" in i && &"_triggered" in i && i._triggered == false:
			if is_debug: print_debug("Question Block Check Failed: " + i.name)
			return false
		elif &"result_counter_value" in i && i.result_counter_value > 0:
			if is_debug: print_debug("Coin Brick Check Failed: " + i.name)
			return false
	
	return true
