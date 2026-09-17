extends Node

const LIFE_MUSHROOM_FILE := "life_mushroom.tscn"
const SUPER_STAR_FILE := "super_star.tscn"
const HAMMER_ITEM_FILE := "hammer_item.tscn"
const DEATH_MUSIC := preload("res://engine/objects/players/prefabs/sounds/music-die.ogg")

var _saved_onetime_blocks: bool = true
var _forced_onetime_blocks: bool = false
var _hit_scene: String = ""
var _hit_ids: PackedStringArray = []
var _ow_zero_lives: bool = false
var _ow_old_death_stop_music: bool = true
var _game_over_handling: bool = false
var _scene_reloading: bool = false
var death_quit_audio: AudioStreamPlayer


func is_active() -> bool:
	if !ProfileManager.current_profile:
		return false
	return !!ProfileManager.current_profile.data.get("master_challenge")


func _ready() -> void:
	Scenes.scene_ready.connect(_on_scene_ready)
	Scenes.pre_scene_changed.connect(_on_pre_scene_changed)
	Scenes.scene_reloaded.connect(_on_scene_reloaded)
	Scenes.scene_shortcut_pressed.connect(_on_quit_while_alive)
	get_tree().root.close_requested.connect(_on_close_game)
	call_deferred(&"_connect_pause_exits")


func _connect_pause_exits() -> void:
	var pause: Control = Scenes.custom_scenes.get("pause")
	if !is_instance_valid(pause):
		return
	var save_room: Node = pause.get_node_or_null("VBoxContainer/GoToSaveRoom")
	var main_menu: Node = pause.get_node_or_null("VBoxContainer/GoToMainMenu")
	var quit_game: Node = pause.get_node_or_null("VBoxContainer/QuitGame")
	if save_room:
		Thunder._connect(save_room.menu_selected, _on_quit_while_alive)
	if main_menu:
		Thunder._connect(main_menu.menu_selected, _on_quit_while_alive)
	if quit_game:
		Thunder._connect(quit_game.menu_selected, _on_pause_quit_opened)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_master_challenge_suspended(false)


func _on_pause_quit_opened() -> void:
	call_deferred(&"_hook_quit_yes")


func _hook_quit_yes() -> void:
	var pause: Control = Scenes.custom_scenes.get("pause")
	if !is_instance_valid(pause):
		return
	var quit_game: Node = pause.get_node_or_null("VBoxContainer/QuitGame")
	if !quit_game:
		return
	var yes: Node = quit_game.get_node_or_null("QuitConfirmLayer/Control/HBoxContainer/Yes")
	if yes:
		Thunder._connect(yes.menu_selected, _on_close_game)


func _on_close_game() -> void:
	_save_master_challenge_suspended(false)


func _physics_process(_delta: float) -> void:
	if !is_active() || !_is_otherworld():
		return
	var pl: Player = Thunder._current_player
	if !pl:
		return
	if Data.values.lives == 0 && pl.death_check_for_lives:
		if !_ow_zero_lives:
			_ow_zero_lives = true
			_ow_old_death_stop_music = pl.death_stop_music
			pl.death_stop_music = true
	elif _ow_zero_lives && Data.values.lives > 0:
		_ow_zero_lives = false
		pl.death_stop_music = _ow_old_death_stop_music


func _on_scene_reloaded() -> void:
	_scene_reloading = true


func _on_pre_scene_changed() -> void:
	if _game_over_handling:
		_apply_game_over_data_reset()
	if !is_active():
		_forced_onetime_blocks = false
		return
	if _scene_reloading:
		_saved_onetime_blocks = Data.values.get("onetime_blocks", true)
		return
	if _forced_onetime_blocks:
		return
	_saved_onetime_blocks = Data.values.get("onetime_blocks", true)
	Data.values.onetime_blocks = true
	_forced_onetime_blocks = true


func _on_scene_ready() -> void:
	_scene_reloading = false
	_wrap_game_over()
	if Input.is_action_pressed(&"ui_page_up") && Console.debug_mode:
		ProfileManager.current_profile.data.master_challenge = true
	
	if !is_active():
		_forced_onetime_blocks = false
		_ow_zero_lives = false
		return
	if _forced_onetime_blocks:
		if !_is_save_or_menu():
			Data.values.onetime_blocks = _saved_onetime_blocks
		_forced_onetime_blocks = false
	if Data.values.get("skip_progress_continue") == true && !_is_save_or_menu():
		_restore_hit_blocks_from_save()
	_apply_otherworld_lives()
	_apply_single_use_blocks()
	if Scenes.current_scene is Map2D && SettingsManager.get_tweak("progress_continue", true):
		if _is_world_1_1():
			Thunder._disconnect(ProfileManager.profile_data_saved_user_display, SecretsManager.game_saved)
			_suppress_save_icon_this_map()
			if Data.values.get("skip_progress_continue") != true:
				_patch_suspended_progress.call_deferred()
		elif Data.values.get("skip_progress_continue") == true:
			if _is_resume_from_suspended():
				_suppress_save_icon_this_map()
		else:
			Thunder._disconnect(ProfileManager.profile_data_saved_user_display, SecretsManager.game_saved)
			_patch_suspended_progress.call_deferred()


func _wrap_game_over() -> void:
	var hud: CanvasLayer = Thunder._current_hud
	if !hud:
		return
	var go: Object = Scenes.custom_scenes.get("game_over")
	if go && hud.game_over_finished.is_connected(go._on_game_over_finished):
		hud.game_over_finished.disconnect(go._on_game_over_finished)
	Thunder._connect(hud.game_over_finished, _on_game_over_finished)


func _on_game_over_finished() -> void:
	if !is_active():
		var go: Object = Scenes.custom_scenes.get("game_over")
		if go:
			go._on_game_over_finished()
		return
	if _game_over_handling:
		return
	_game_over_handling = true
	_clear_session_persistents()
	Data.technical_values.remaining_continues = 0
	_rollback_current_world_progress()

	var dest: String = ""
	if ProfileManager.current_profile:
		dest = str(ProfileManager.current_profile.data.get("current_world", ""))
	if dest.is_empty():
		dest = ProjectSettings.get_setting("application/thunder_settings/save_game_room_path")

	await Scenes.goto_scene_with_transition(dest, &"fade", func(t):
		t.with_animation("to_black_linear")
		t.with_speeds(3.0, 1.0)
	)
	_game_over_handling = false


func _apply_game_over_data_reset() -> void:
	Data.reset_all_values()
	Data.values.lives = ProjectSettings.get_setting("application/thunder_settings/player/default_lives", 4)
	Data.values.skip_progress_continue = true
	_clear_session_persistents()


func _apply_otherworld_lives() -> void:
	_ow_zero_lives = false
	if !_is_otherworld():
		return
	var pl: Player = Thunder._current_player
	if !pl:
		return
	pl.death_check_for_lives = true
	if Data.values.lives == 0:
		_ow_zero_lives = true
		_ow_old_death_stop_music = pl.death_stop_music
		pl.death_stop_music = true


func _is_otherworld() -> bool:
	if !is_instance_valid(Scenes.current_scene):
		return false
	return Scenes.current_scene.scene_file_path.contains("otherworld")


func _is_save_or_menu() -> bool:
	if !is_instance_valid(Scenes.current_scene):
		return false
	var path: String = Scenes.current_scene.scene_file_path
	return (
		"save_game_room" in path || "main_menu" in path || "_title" in path ||
		"starting" in path
	)


func _is_resume_from_suspended() -> bool:
	var csv: Variant = Data.technical_values.get("custom_saved_values")
	return typeof(csv) == TYPE_DICTIONARY && csv.has("mc_hit_scene")


func _is_world_1_1() -> bool:
	var wl: Vector2i = _resume_world_level()
	return wl.x == 1 && wl.y == 1


func _resume_world_level() -> Vector2i:
	if Scenes.current_scene is Map2D:
		var ms: MarkerSpace = Scenes.current_scene.get_first_marker_space()
		if ms:
			return Vector2i(ms.space_name, ms.get_next_marker_id(false) + 1)
	if is_instance_valid(Scenes.current_scene):
		var parsed: Vector2i = _parse_world_level_from_path(Scenes.current_scene.scene_file_path)
		if parsed.x > 0:
			return parsed
	if !ProfileManager.current_profile:
		return Vector2i.ZERO
	var wn: PackedStringArray = str(ProfileManager.current_profile.data.get("world_numbers", "")).split("-")
	if wn.size() > 1:
		return Vector2i(int(wn[0]), int(wn[1]))
	return Vector2i.ZERO


func _parse_world_level_from_path(path: String) -> Vector2i:
	var file: String = path.get_file()
	var regex := RegEx.create_from_string(r"(\d+)-(\d+)\.t?scn")
	var matched: RegExMatch = regex.search(file)
	if !matched:
		return Vector2i.ZERO
	return Vector2i(int(matched.get_string(1)), int(matched.get_string(2)))


func _rollback_current_world_progress() -> void:
	if !ProfileManager.current_profile:
		return
	var world: int = _current_world_number()
	if world <= 0:
		return
	var profile: ProfileManager.Profile = ProfileManager.current_profile
	var completed: Variant = profile.data.get("completed_levels", [])
	if completed is Array:
		var kept: Array = []
		for level_path in completed:
			if _level_belongs_to_world(str(level_path), world):
				continue
			kept.append(level_path)
		profile.data.completed_levels = kept
	profile.set_world_numbers(world, 1)
	profile.data.erase("next_level")
	if ProfileManager.profiles.has("suspended"):
		ProfileManager.delete_profile("suspended")
	ProfileManager.save_current_profile()


func _current_world_number() -> int:
	if is_instance_valid(Scenes.current_scene):
		var from_scene: int = _world_number_from_path(Scenes.current_scene.scene_file_path)
		if from_scene > 0:
			return from_scene
	var wl: Vector2i = _resume_world_level()
	if wl.x > 0:
		return wl.x
	if !ProfileManager.current_profile:
		return 0
	return _world_number_from_path(str(ProfileManager.current_profile.data.get("current_world", "")))


func _world_number_from_path(path: String) -> int:
	var resolved: String = Scenes.get_scene_path(path)
	var parsed: Vector2i = _parse_world_level_from_path(resolved)
	if parsed.x > 0:
		return parsed.x
	var map_regex := RegEx.create_from_string(r"(?:expert_)?map_(\d+)")
	var map_match: RegExMatch = map_regex.search(resolved.get_file())
	if map_match:
		return int(map_match.get_string(1))
	var dir_regex := RegEx.create_from_string(r"/world_(\d+)/")
	var dir_match: RegExMatch = dir_regex.search(resolved)
	if dir_match:
		return int(dir_match.get_string(1))
	return 0


func _level_belongs_to_world(path: String, world: int) -> bool:
	if world <= 0:
		return false
	var resolved: String = Scenes.get_scene_path(path)
	if resolved.contains("/world_%d/" % world):
		return true
	return _parse_world_level_from_path(resolved).x == world


func _suppress_save_icon_this_map() -> void:
	Thunder._disconnect(ProfileManager.profile_data_saved_user_display, SecretsManager.game_saved)
	await get_tree().physics_frame
	if is_inside_tree():
		SecretsManager.set_save_icon()


func _is_hit_tracking_ignored() -> bool:
	if !is_instance_valid(Scenes.current_scene):
		return true
	var path: String = Scenes.current_scene.scene_file_path
	return path.contains("climbing_minigame") || path.contains("8-4_boss")


func _apply_single_use_blocks() -> void:
	if !is_instance_valid(Scenes.current_scene):
		return
	if _is_hit_tracking_ignored():
		return
	if !(Scenes.current_scene is Level):
		return
	var path: String = Scenes.current_scene.scene_file_path
	if path != _hit_scene:
		_hit_scene = path
		_hit_ids.clear()
		_write_hit_blocks_to_custom_values()

	var blocks: Array[StaticBumpingBlock] = []
	_collect_blocks(Scenes.current_scene, blocks)
	for block in blocks:
		if !_is_tracked_block(block):
			if !_saved_onetime_blocks && block.exists_once:
				block.queue_free()
			continue
		var id: String = _block_id(block)
		if _hit_ids.has(id):
			if block.initially_visible_and_solid:
				_deactivate_visible_block(block)
			else:
				block.queue_free()
			continue
		Thunder._connect(block.bumped, _on_tracked_block_bumped.bind(block))


func _collect_blocks(node: Node, out: Array[StaticBumpingBlock]) -> void:
	if node is StaticBumpingBlock:
		out.append(node)
	for child in node.get_children():
		_collect_blocks(child, out)


func _is_tracked_block(block: StaticBumpingBlock) -> bool:
	if !block.result:
		return false
	if !"creation_nodepack" in block.result:
		return false
	var pack: Resource = block.result.creation_nodepack
	if !pack:
		return false
	var p: String = str(pack.resource_path)
	return p.ends_with(LIFE_MUSHROOM_FILE) || p.ends_with(SUPER_STAR_FILE) || p.ends_with(HAMMER_ITEM_FILE)


func _block_id(block: StaticBumpingBlock) -> String:
	return "%.0f,%.0f" % [block.global_position.x, block.global_position.y]


func _on_tracked_block_bumped(block: StaticBumpingBlock) -> void:
	if !is_instance_valid(block):
		return
	var id: String = _block_id(block)
	if !_hit_ids.has(id):
		_hit_ids.append(id)
		_write_hit_blocks_to_custom_values()


func _deactivate_visible_block(block: StaticBumpingBlock) -> void:
	block.active = false
	block.result = null
	block._triggered = true
	var sprites: Node2D = block.get_node_or_null("Sprites")
	if sprites:
		sprites.visible = true
	var spr: AnimatedSprite2D = block.get_node_or_null("Sprites/AnimatedSprite2D")
	if spr && spr.sprite_frames && spr.sprite_frames.has_animation(&"empty"):
		spr.animation = &"empty"


func _clear_hit_blocks() -> void:
	_hit_scene = ""
	_hit_ids.clear()
	var csv: Variant = Data.technical_values.get("custom_saved_values")
	if typeof(csv) == TYPE_DICTIONARY:
		csv.erase("mc_hit_scene")
		csv.erase("mc_hit_ids")


func _clear_session_persistents() -> void:
	_hit_scene = ""
	_hit_ids.clear()
	Data.technical_values.custom_saved_values = {}
	if Data.values.has("item"):
		Data.values.item = ""


func _write_hit_blocks_to_custom_values() -> void:
	var csv: Variant = Data.technical_values.get("custom_saved_values")
	if typeof(csv) != TYPE_DICTIONARY:
		csv = {}
		Data.technical_values.custom_saved_values = csv
	csv["mc_hit_scene"] = _hit_scene
	csv["mc_hit_ids"] = Array(_hit_ids)


func _restore_hit_blocks_from_save() -> void:
	var csv: Variant = Data.technical_values.get("custom_saved_values")
	if typeof(csv) != TYPE_DICTIONARY || !csv.has("mc_hit_scene"):
		_clear_hit_blocks()
		return
	_hit_scene = str(csv.get("mc_hit_scene", ""))
	_hit_ids = PackedStringArray()
	for id in csv.get("mc_hit_ids", []):
		_hit_ids.append(str(id))


func _apply_mc_suspended_rules(profile: ProfileManager.Profile) -> int:
	_write_hit_blocks_to_custom_values()
	var saved_values: Dictionary = profile.data.get("saved_values", {})
	var lives: int = int(saved_values.get("lives", 0)) - 1
	saved_values.lives = lives
	if Scenes.current_scene is Level:
		saved_values.onetime_blocks = false
	profile.data.saved_values = saved_values
	profile.data.erase("saved_player_state")
	profile.data.custom_technical_values = Data.technical_values.custom_saved_values.duplicate(true)
	profile.data.remaining_continues = Data.technical_values.remaining_continues
	return lives


func _can_write_suspended() -> bool:
	if !is_active() || _game_over_handling:
		return false
	if !SettingsManager.get_tweak("progress_continue", true):
		return false
	if !ProfileManager.current_profile:
		return false
	if _is_save_or_menu():
		return false
	if ProfileManager.current_profile.data.get("executed") && !Console.cv.can_save_suspended_with_console:
		return false
	var pl: Player = Thunder._current_player
	if pl && pl.is_dying:
		return false
	if int(Data.values.get("lives", -1)) < 0:
		return false
	return true


func _suspended_scene_path() -> String:
	if Scenes.current_scene is Map2D:
		return Scenes.current_scene.scene_file_path
	var dest: String = str(ProfileManager.current_profile.data.get("current_world", ""))
	if dest.is_empty() && is_instance_valid(Scenes.current_scene):
		dest = Scenes.current_scene.scene_file_path
	return dest


func _fill_suspended_titles(data: Dictionary) -> void:
	if Scenes.current_scene is Map2D:
		var ms: MarkerSpace = Scenes.current_scene.get_first_marker_space()
		if ms:
			data.title_prefix = ms.progress_title_prefix
			var saved_level: String = str(ms.get_next_marker_id(false) + 1)
			data.title_level = ms.progress_title_level.format([str(ms.space_name), saved_level])
			return
	if ProfileManager.current_profile.data.get("mario_forever_expert"):
		data.title_prefix = "expert world\\n"
	else:
		data.title_prefix = "world\\n"
	var wl: Vector2i = _resume_world_level()
	if wl.x > 0 && wl.y > 0:
		data.title_level = "%d - %d" % [wl.x, wl.y]
		return
	var wn: String = str(ProfileManager.current_profile.data.get("world_numbers", "")).replace("-", " - ")
	data.title_level = wn if !wn.is_empty() else "x"


func _save_master_challenge_suspended(show_icon: bool) -> void:
	if !_can_write_suspended():
		return
	if _is_world_1_1():
		if ProfileManager.profiles.has("suspended"):
			ProfileManager.delete_profile("suspended")
		return
	if _resume_world_level().y <= 1:
		return
	var scene_path: String = _suspended_scene_path()
	if scene_path.is_empty():
		return
	var lives_after: int = int(Data.values.get("lives", 0)) - 1
	if lives_after < 0:
		if ProfileManager.profiles.has("suspended"):
			ProfileManager.delete_profile("suspended")
		return
	var profile := ProfileManager.Profile.new()
	profile.name = "suspended"
	profile.data.saved_values = Data.values.duplicate(true)
	profile.data.saved_profile = ProfileManager.current_profile.name
	profile.data.saved_profile_data = ProfileManager.current_profile.data
	profile.data.scene = scene_path
	_fill_suspended_titles(profile.data)
	_apply_mc_suspended_rules(profile)
	ProfileManager.profiles.suspended = profile
	ProfileManager.save_profile_data("suspended", profile.data)
	if show_icon:
		ProfileManager.profile_data_saved_user_display.emit("suspended")


func _patch_suspended_progress() -> void:
	if !is_inside_tree() || !is_active():
		SecretsManager.set_save_icon()
		return
	if !ProfileManager.profiles.has("suspended"):
		SecretsManager.set_save_icon()
		return
	var profile: ProfileManager.Profile = ProfileManager.profiles.suspended
	if profile.data.get("saved_profile") != ProfileManager.current_profile.name:
		SecretsManager.set_save_icon()
		return
	if profile.data.get("scene") != Scenes.current_scene.scene_file_path:
		SecretsManager.set_save_icon()
		return
	if _is_world_1_1():
		ProfileManager.delete_profile("suspended")
		SecretsManager.set_save_icon()
		return
	var lives: int = _apply_mc_suspended_rules(profile)
	if lives < 0:
		ProfileManager.delete_profile("suspended")
		SecretsManager.set_save_icon()
		return
	ProfileManager.save_profile_data("suspended", profile.data)
	SecretsManager.set_save_icon()
	ProfileManager.profile_data_saved_user_display.emit("suspended")


func _on_quit_while_alive() -> void:
	if !is_active() || _is_save_or_menu():
		return
	var pl: Player = Thunder._current_player
	if pl && pl.is_dying:
		return
	_save_master_challenge_suspended(true)
	if !pl:
		return
	var sfx: AudioStream = DEATH_MUSIC
	if pl.suit && pl.suit.sound_death:
		sfx = pl.suit.sound_death
	else:
		var lines: Array = CharacterManager.get_voice_line("death")
		if lines:
			sfx = lines[randi_range(0, lines.size() - 1)]
	var player: AudioStreamPlayer = Audio.play_1d_sound(sfx, true, {
		ignore_pause = true,
		bus = "Music",
	})
	if is_instance_valid(player):
		player.reparent(self)
		death_quit_audio = player


func award_click_bonus_lives() -> void:
	for i in 3:
		Thunder.add_lives(1)
		var _sfx: AudioStream = CharacterManager.get_sound_replace(Data.LIFE_SOUND, Data.LIFE_SOUND, "1up", false)
		Audio.play_1d_sound(_sfx)
		if i < 2:
			await get_tree().create_timer(0.6, false, false, true).timeout
