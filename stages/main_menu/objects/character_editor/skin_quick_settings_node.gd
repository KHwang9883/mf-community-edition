extends Node

const CATEGORY_SUIT_SELECTION = preload("res://stages/main_menu/objects/character_editor/category_suit_selection.tscn")
const AUDIO_TEST_SELECTION = preload("res://stages/main_menu/objects/character_editor/audio_test_selection.tscn")
const SKIN_SETTINGS_GLOBAL = preload("res://stages/main_menu/objects/character_editor/skin_settings_global.tscn")

const DEFAULT_LINES = {
	"level_complete": preload("res://engine/scripts/classes/level/complete.ogg"),
	"coin": preload("res://engine/objects/items/coin/coin.wav"),
	"enemy_stomp": preload("res://engine/objects/enemies/_sounds/stomp.wav"),
	"enemy_bump": preload("res://engine/objects/bumping_blocks/_sounds/bump.wav"),
	"enemy_kick": preload("res://engine/objects/players/prefabs/sounds/kick.wav"),
	"spring_bounce": preload("res://engine/objects/springboard/sounds/springboard.wav"),
	"block_appear": preload("res://engine/objects/bumping_blocks/_sounds/appear.wav"),
	"block_bump": preload("res://engine/objects/bumping_blocks/_sounds/bump.wav"),
	"block_break": preload("res://engine/objects/bumping_blocks/_sounds/break.wav"),
	"hud_time_hurry": preload("res://engine/components/hud/sounds/timeout.wav"),
	"hud_time_score": preload("res://engine/components/hud/sounds/scoring.wav"),
	"hud_pause_open": preload("res://engine/components/pause/sounds/pause_open.wav"),
	"hud_pause_close": null,
	"menu_start_song": preload("res://engine/scenes/main_menu/sounds/lets.wav"),
	"menu_enter": preload("res://engine/components/ui/_sounds/select_enter.wav"),
	"level_cutscene_song": preload("res://engine/scenes/main_menu/sounds/lets.wav"),
	"1up": preload("res://engine/objects/players/prefabs/sounds/1up.wav"),
	"hud_acceptance": preload("res://engine/objects/players/prefabs/sounds/powerup.wav"),
	"message_box": preload("res://engine/objects/bumping_blocks/message_block/message_block.wav"),
	"bonus_activate": preload("res://engine/objects/players/prefabs/sounds/powerup.wav"),
	"bonus_reserve": preload("res://sfx/item-reserve.wav"),
	"checkpoint_switch": preload("res://engine/objects/core/checkpoint/sounds/switch.wav"),
	"menu_mouse_hover": preload("res://engine/components/ui/_sounds/select_mouse_hover.mp3"),
	"menu_select": preload("res://engine/components/ui/_sounds/select_main.wav"),
	"menu_failure": preload("res://engine/components/ui/_sounds/select_failure.wav"),
	"menu_toggle": preload("res://engine/scenes/main_menu/sounds/change.wav"),
	"menu_fade_out": preload("res://engine/components/ui/_sounds/fadeout.wav"),
	"map_level_enter": preload("res://engine/objects/items/coin/coin.wav"),
	"menu_select_short": preload("res://engine/components/hud/sounds/scoring.wav"),
	"game_over": preload("res://engine/objects/players/prefabs/sounds/music-gameover.ogg"),
	"bowser_hurt": preload("res://engine/objects/bosses/bowser/sounds/bowser_hurt.wav"),
	"bowser_be_happy": preload("res://engine/objects/bosses/bowser/sounds/bowser_died.wav"),
	#"bowser_fall": preload("res://engine/objects/bosses/bowser/sounds/bowser_fall.wav"),
	#"bowser_lava_love": preload("res://engine/objects/bosses/bowser/sounds/bowser_into_lava.wav"),
	"stun": preload("res://engine/objects/projectiles/sounds/stun.wav"),
	"fireball_bump": null,
	"starman": preload("res://engine/objects/powerups/super_star/music-starman.it"),
	"pipe_cutscene": preload("res://engine/objects/players/prefabs/sounds/pipe_cutscene.wav"),
}

var skin_tweaks: Dictionary = {}
var mus_tween: Tween

@onready var menu_controller: MenuItemsController = $"../.."
@onready var par: HSeparator = $".."
@onready var camera_2d: Camera2D = $"../../../Camera2D"
@onready var skin_sound_test: MenuItemsController = $"../../../SkinSoundTest"

func _on_quick_skin_settings_button_selection_entered() -> void:
	get_tree().call_group(&"_skin_suit_category", &"queue_free")
	
	if SkinsManager.current_skin && SkinsManager.custom_textures.has(SkinsManager.current_skin):
		var _arr := PackedStringArray(SkinsManager.custom_textures[SkinsManager.current_skin].keys())
		_arr.sort()
		for i in _arr.size():
			var _cat_suit_sel = CATEGORY_SUIT_SELECTION.instantiate()
			_cat_suit_sel.powerup_name = _arr[i]
			_cat_suit_sel.get_node("Label").text = "%s suit" % [_arr[i].replacen("_", " ")]
			_cat_suit_sel.reset_to = _arr.size() - i
			par.add_sibling(_cat_suit_sel)
	#elif SkinsManager.current_skin.is_empty():
	#	var _cat_suit_sel = SKIN_SETTINGS_GLOBAL.instantiate()
	#	par.add_sibling(_cat_suit_sel)
		
	
	menu_controller._update_selectors()
	_resize_quick_skin()


func _on_exit_selection_entered() -> void:
	if skin_tweaks.is_empty():
		return
	print("Skin Suit tweaks saved!")
	for powerup in skin_tweaks:
		var _skin_path: String
		var _current_skin = SkinsManager.current_skin
		if !_current_skin:
			_current_skin = "none"
			powerup = "_all_suits"
		_skin_path = SkinsManager.base_dir \
			.path_join(_current_skin) \
			.path_join(powerup) \
			.path_join("suit_tweaks.json")
		SettingsManager.save_data(skin_tweaks[powerup], _skin_path, powerup, true)
		if !SkinsManager.suit_tweaks.has(_current_skin):
			SkinsManager.suit_tweaks[_current_skin] = {}
		var file_path: String = SkinsManager.base_dir + "/" + _current_skin + "/" + powerup
		if _current_skin == "none":
			SkinsManager._load_suit_tweaks(_current_skin, powerup, file_path)
			break
		else:
			SkinsManager.suit_tweaks[_current_skin][powerup] = skin_tweaks[powerup]
	
	skin_tweaks = {}


func _on_submenu_exit_selection_entered() -> void:
	get_tree().call_group(&"_submenu_skin_suit_category", &"queue_free")
	menu_controller.size.y = 432
	_resize_skin_suit()


func _base_resize_menu(_control: Control) -> void:
	# WHAT THE FUCK IS WRONG
	for i in 8:
		if !is_inside_tree(): return
		#print(_control.get_combined_minimum_size().y)
		if !_control.focused && i > 2: return
		if _control.size.y > _control.get_combined_minimum_size().y:
			_control.size.y = _control.get_combined_minimum_size().y
		camera_2d.update_limit()
		await get_tree().physics_frame


func _resize_skin_suit() -> void:
	_base_resize_menu($"../../../SkinSuitSettings")

func _resize_submenu() -> void:
	_base_resize_menu($"../../../SkinSuitSettingsSubmenu")

func _resize_quick_skin() -> void:
	_base_resize_menu($"../../../SkinTweaks")

func _resize_sound_test() -> void:
	_base_resize_menu(skin_sound_test)

func _resize_global_skin_tweaks() -> void:
	_base_resize_menu($"../../../SkinGlobalTweaks")


func _on_skin_suit_exit_selection_entered() -> void:
	_resize_quick_skin()


func _on_sound_test_selection_entered() -> void:
	if 0 in Audio._music_channels:
		var mus_ch = Audio._music_channels[0]
		if is_instance_valid(mus_ch):
			if mus_tween: mus_tween.kill()
			mus_tween = create_tween()
			mus_tween.tween_property(mus_ch, "volume_linear", 0, 0.6)
	
	var _arr := PackedStringArray(CharacterManager.voice_lines.get(CharacterManager.get_character_name(), "Mario").keys())
	_arr.sort()
	_arr.reverse()
	for i in _arr.size():
		var _cat_suit_sel = AUDIO_TEST_SELECTION.instantiate()
		var voice_line = CharacterManager.get_voice_line(_arr[i])
		if voice_line.is_empty():
			if _arr[i] == "level_complete" && SettingsManager.get_tweak("alt_completion_music", false):
				_cat_suit_sel.selected_sound = preload("res://music/complete_tweaked.ogg")
			else:
				_cat_suit_sel.selected_sound = DEFAULT_LINES.get(_arr[i], null)
				#print(_arr[i])
		else:
			if _arr[i] == "starman":
				for j in voice_line:
					if "loop" in j: j.loop = true
			_cat_suit_sel.sounds_arr = voice_line
			if SkinsManager.current_skin in SkinsManager.misc_sounds:
				_cat_suit_sel.is_custom = SkinsManager.misc_sounds[SkinsManager.current_skin].has(_arr[i])
		_cat_suit_sel.get_node("Label").text = _arr[i]
		skin_sound_test.get_node("HSeparatorSpawnTweaks").add_sibling(_cat_suit_sel)
	#elif SkinsManager.current_skin.is_empty():
	#	var _cat_suit_sel = SKIN_SETTINGS_GLOBAL.instantiate()
	#	par.add_sibling(_cat_suit_sel)
		
	
	skin_sound_test._update_selectors()
	menu_controller._update_selectors()
	skin_sound_test.move_selector.call_deferred(0, true)
	skin_sound_test.size.y = skin_sound_test.get_combined_minimum_size().y
	camera_2d.force_update_scroll()
	camera_2d.update_limit.call_deferred()
	camera_2d.reset_physics_interpolation()
	_resize_quick_skin()


func _on_audiotest_exit_selection_entered() -> void:
	if mus_tween: mus_tween.kill()
	if 0 in Audio._music_channels:
		var mus_ch = Audio._music_channels[0]
		if is_instance_valid(mus_ch):
			#Audio.fade_music_1d_player(mus_ch, -2, 0.6)
			mus_tween = create_tween()
			mus_tween.tween_property(mus_ch, "volume_linear", 0.8, 0.6)
	
	get_tree().call_group(&"_sounds", &"queue_free")
	get_tree().call_group(&"preview_sound", &"queue_free")
	skin_sound_test.size.y = 432
	skin_sound_test._update_selectors()
	_resize_sound_test()


func _on_skin_global_tweaks_exit_selection_entered() -> void:
	if !"global" in skin_tweaks:
		return
	
	var _skin_path: String
	var _current_skin = SkinsManager.current_skin
	if !_current_skin:
		return
	_skin_path = SkinsManager.base_dir \
		.path_join(_current_skin) \
		.path_join("global_skin_tweaks.json")
	print("Global skin tweaks saved!")
	SettingsManager.save_data(skin_tweaks.global, _skin_path, "Global Skin Tweaks", true)
	#if !SkinsManager.misc_textures[_current_skin].has("global_skin_tweaks"):
	#	SkinsManager.misc_textures[_current_skin].global_skin_tweaks = {}
	#var file_path: String = SkinsManager.base_dir + "/" + _current_skin
	SkinsManager.misc_textures[_current_skin].global_skin_tweaks = skin_tweaks.global
	
	skin_tweaks = {}


func _on_skin_setup_entered() -> void:
	var _node = $"../../../QuickSkinSettings/HBoxContainer2"
	_node.is_blocked = SkinsManager.current_skin.is_empty()
	var _label_node: Label = $"../../../QuickSkinSettings/HBoxContainer2/Label"
	if SkinsManager.current_skin.is_empty():
		_label_node.add_theme_color_override(&"font_color", Color("#606060"))
	else:
		_label_node.add_theme_color_override(&"font_color", Color("#cacaff"))
