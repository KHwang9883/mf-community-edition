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
	"hud_timeout": preload("res://engine/components/hud/sounds/timeout.wav"),
	"hud_pause_open": preload("res://engine/components/pause/sounds/pause_open.wav"),
	"hud_pause_close": null,
	"menu_start_song": preload("res://engine/scenes/main_menu/sounds/lets.wav"),
	"menu_enter": preload("res://engine/components/ui/_sounds/select_enter.wav"),
	"level_cutscene_song": preload("res://engine/scenes/main_menu/sounds/lets.wav"),
	"1up": preload("res://engine/objects/players/prefabs/sounds/1up.wav"),
	"hud_acceptance": preload("res://engine/objects/players/prefabs/sounds/powerup.wav"),
	"message_box": preload("res://engine/objects/bumping_blocks/message_block/message_block.wav"),
	"bonus_activate": preload("res://engine/objects/players/prefabs/sounds/powerup.wav"),
	"checkpoint_switch": preload("res://engine/objects/core/checkpoint/sounds/switch.wav"),
}

var skin_tweaks: Dictionary = {}

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


func _resize_skin_suit() -> void:
	# WHAT THE FUCK IS WRONG
	for i in 8:
		if !is_inside_tree(): return
		var _control: Control = $"../../../SkinSuitSettings"
		#print(_control.get_combined_minimum_size().y)
		if !_control.focused && i > 2: return
		if _control.size.y > _control.get_combined_minimum_size().y:
			_control.size.y = _control.get_combined_minimum_size().y
		camera_2d.update_limit()
		await get_tree().physics_frame


func _resize_submenu() -> void:
	for i in 8:
		if !is_inside_tree(): return
		var _control: Control = $"../../../SkinSuitSettingsSubmenu"
		if !_control.focused && i > 2: return
		if _control.size.y > _control.get_combined_minimum_size().y:
			_control.size.y = _control.get_combined_minimum_size().y
		camera_2d.update_limit()
		await get_tree().physics_frame


func _resize_quick_skin() -> void:
	for i in 8:
		if !is_inside_tree(): return
		var _control: Control = $"../../../SkinTweaks"
		if !_control.focused && i > 2: return
		if _control.size.y > _control.get_combined_minimum_size().y:
			_control.size.y = _control.get_combined_minimum_size().y
		camera_2d.update_limit()
		await get_tree().physics_frame


func _resize_sound_test() -> void:
	for i in 8:
		if !is_inside_tree(): return
		if !skin_sound_test.focused && i > 2: return
		if skin_sound_test.size.y > skin_sound_test.get_combined_minimum_size().y:
			skin_sound_test.size.y = skin_sound_test.get_combined_minimum_size().y
		camera_2d.update_limit()
		await get_tree().physics_frame


func _on_skin_suit_exit_selection_entered() -> void:
	_resize_quick_skin()


func _on_sound_test_selection_entered() -> void:
	var mus_ch = Audio._music_channels[0]
	if is_instance_valid(mus_ch):
		Audio.fade_music_1d_player(mus_ch, -60, 0.6)
	
	get_tree().call_group(&"_sounds", &"queue_free")
	
	var _arr := PackedStringArray(CharacterManager.voice_lines.get(CharacterManager.get_character_name(), "Mario").keys())
	_arr.sort()
	for i in _arr.size():
		var _cat_suit_sel = AUDIO_TEST_SELECTION.instantiate()
		var voice_line = CharacterManager.get_voice_line(_arr[i])
		if voice_line.is_empty():
			if _arr[i] == "level_complete" && SettingsManager.get_tweak("alt_completion_music", false):
				_cat_suit_sel.selected_sound = preload("res://music/complete_tweaked.ogg")
			else:
				_cat_suit_sel.selected_sound = DEFAULT_LINES.get(_arr[i], null)
		else:
			_cat_suit_sel.sounds_arr = voice_line
		_cat_suit_sel.get_node("Label").text = _arr[i]
		skin_sound_test.get_node("HSeparatorSpawnTweaks").add_sibling(_cat_suit_sel)
	#elif SkinsManager.current_skin.is_empty():
	#	var _cat_suit_sel = SKIN_SETTINGS_GLOBAL.instantiate()
	#	par.add_sibling(_cat_suit_sel)
		
	
	menu_controller._update_selectors()
	_resize_quick_skin()


func _on_audiotest_exit_selection_entered() -> void:
	#if audio_tween: audio_tween.kill()
	var mus_ch = Audio._music_channels[0]
	if is_instance_valid(mus_ch):
		Audio.fade_music_1d_player(mus_ch, -2, 0.6)
		#audio_tween = create_tween()
		#audio_tween.tween_property(mus_ch, "volume_linear", 0.8, 0.5)
	
	get_tree().call_group(&"_sounds", &"queue_free")
	skin_sound_test.size.y = 432
	skin_sound_test._update_selectors()
	_resize_sound_test()
