extends Level

@onready var final_boss_cell = $FinalBossCell
@onready var music_loader: Node = $MusicLoader
var _finish_command_started: bool
@onready var antiafk_expert_mode: CanvasLayer = $MusicLoader/AntiafkExpertMode

func _ready() -> void:
	super()
	Thunder._connect(Console.executed, func(command_name, args):
		if command_name != "finish": return
		if _finish_command_started: return
		var nd = Scenes.current_scene.get_node_or_null("Bowser")
		if !nd: return
		_finish_command_started = true
		nd.health = 0
		nd.die()
	)

func finish(walking: bool = false, walking_dir: int = 1) -> void:
	if !walking: return
	if !Thunder._current_player: return
	level_completed.emit()
	final_boss_cell.cutscene()
	music_loader.play_buffered()
	Data.values.onetime_blocks = true
	antiafk_expert_mode.empty_item_stock()
	Thunder._current_player.left_right = 0
	Thunder._current_hud.timer.paused = true

	get_tree().call_group_flags(
		get_tree().GROUP_CALL_DEFERRED,
		&"end_level_sequence",
		&"_on_level_end"
	)
	
	Data.values.checkpoint = -1
	Data.values.checked_cps = []
	
	if completion_write_save:
		var profile = ProfileManager.current_profile
		var path = scene_file_path if !completion_write_save_path_override else completion_write_save_path_override
		if Data.values.get("map_force_selected_marker"):
			Data.values.map_force_go_next = true
			Data.values.map_force_old_marker = ""
		if !profile.has_completed(path):
			profile.complete_level(path)
			ProfileManager.save_current_profile()

func throw_to_scene() -> void:
	var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)

	if jump_to_scene:
		if !_crossfade:
			TransitionManager.accept_transition(
				load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
					.instantiate()
					.with_speeds(0.04, -0.1)
					.with_pause()
					.on_player_after_middle(completion_center_on_player_after_transition)
			)
			
			await TransitionManager.transition_middle
			Scenes.goto_scene(jump_to_scene)
		else:
			TransitionManager.accept_transition(
				load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
					.instantiate()
					.with_scene(jump_to_scene)
			)
	else:
		printerr("[Level] Jump to scene is not defined in the level.")
