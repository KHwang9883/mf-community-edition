@warning_ignore("missing_tool")
extends Level

const CASTLE_CRASH = preload("res://engine/scenes/castle_cutscene/sounds/castle_crash.wav")

@export var climbing_scene: String = "res://stages/extra/climbing_minigame/climbing_lava_run.tscn"
@export var climbing_set_difficulty := 0
@export var climbing_after_scene: String = ""
@export var ignore_tweak: bool = false
@onready var lava_bowser: Node2D = $LavaBowser



func finish(walking: bool = false, walking_dir: int = 1) -> void:
	if !ignore_tweak && !SettingsManager.get_tweak("minigames_in_main_worlds", true):
		super(walking, walking_dir)
		return
	if _level_has_completed: return
	_level_has_completed = true
	if !Thunder._current_player: return
	level_completed.emit()
	if (
		Thunder.autosplitter.can_split_on("level_end_always") ||
		(Thunder.autosplitter.can_split_on("level_end_no_boss") && !has_meta(&"boss_got_defeated"))
	):
		Thunder.autosplitter.split("Level Ended")
	Thunder.autosplitter.update_il_counter()
	print("[Game] Level complete.")
	
	Thunder._current_hud.timer.paused = true
	Thunder._current_player.completed = true
	Audio.stop_all_musics()
	
	Data.values.onetime_blocks = true
	Thunder._current_player.left_right = 0
	
	Audio.play_1d_sound(CASTLE_CRASH)
	Thunder._current_camera.shock(9, Vector2(4, 4))
	var tw = lava_bowser.create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_parallel()
	tw.tween_property(lava_bowser, "position:y", lava_bowser.position.y + 240, 4)
	tw.tween_property(lava_bowser, "modulate:a", 0.0, 2.5)
	lava_bowser.get_node("Area2D/CollisionShape2D").disabled = true
	
	await get_tree().create_timer(1.0, false, false).timeout
	
	get_tree().call_group(&"1-4_castle", &"set_falling")
	falling_below_y_offset = 666
	
	var _voices = CharacterManager.get_voice_line("fall")
	var pl := Thunder._current_player
	if pl:
		Audio.play_sound(_voices[randi_range(0, len(_voices) - 1)], pl, true, { ignore_pause = true })
		pl.gravity_scale = 0.1
		if pl.speed.y < 0:
			pl.speed.y = 0
		pl.debug_god = true
	
	await get_tree().create_timer(3.0, false, false).timeout
	
	var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)
	Data.values.checkpoint = -1
	Data.values.checked_cps = []
	
	if climbing_scene:
		Data.values['lavarun_difficulty'] = climbing_set_difficulty
		Data.values['lavarun_after'] = climbing_after_scene
		if !_crossfade:
			TransitionManager.accept_transition(
				load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
					.instantiate()
					.with_speeds(0.04, -0.1)
					.with_pause()
					.on_player_after_middle(completion_center_on_player_after_transition)
			)
			
			await TransitionManager.transition_middle
			Scenes.goto_scene(climbing_scene)
		else:
			TransitionManager.accept_transition(
				load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
					.instantiate()
					.with_scene(climbing_scene)
			)
	else:
		printerr("[Level] Jump to scene is not defined in the level.")
