extends Node2D

signal coin_checked_success

@export_file("*.tscn", "*.scn") var toad_scene: String
@export var string_node_path: NodePath = ^"../HUD/ToadWarp"

@onready var string_node: Node = get_node_or_null(string_node_path)

func _ready() -> void:
	if !SettingsManager.get_tweak("minigames_in_main_worlds", true):
		return
	Scenes.current_scene.level_completed.connect(check_for_coins, CONNECT_DEFERRED)


func check_for_coins() -> void:
	for i in get_children():
		if i.is_in_group(&"coin"):
			print_debug("Coin Check Failed: " + i.name)
			return
		if !&"result_counter_value" in i && &"_triggered" in i && i._triggered == false:
			print_debug("Question Block Check Failed: " + i.name)
			return
		elif &"result_counter_value" in i && i.result_counter_value > 0:
			print_debug("Coin Brick Check Failed: " + i.name)
			return
	
	Data.technical_values.map_scene = Scenes.current_scene.jump_to_scene
	Scenes.current_scene.jump_to_scene = toad_scene
	Scenes.current_scene.completion_center_on_player_after_transition = true
	
	if string_node:
		string_node.activate()
