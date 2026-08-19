extends "res://stages/main_menu/objects/character_editor/skin_suit_category_sel.gd"

func _ready() -> void:
	h_separator_spawn = $"../../SkinGlobalTweaks/HSeparatorSpawnTweaks"
	if valu:
		valu.modulate.a = 0.0
		_template = valu.text
		_update_text()
		SettingsManager.settings_saved.connect(_update_text)

func _handle_select(mouse_input: bool = false) -> void:
	if !SkinsManager.current_skin: return
	# Custom skin
	get_tree().call_group(&"_skin_suit_tweak", &"queue_free")
	var _char = CharacterManager.get_character_name()
	if !CharacterManager.misc_textures.has(_char) || !"global_skin_tweaks" in CharacterManager.misc_textures[_char]:
		printerr("Warning: No global skin tweaks for char: ", _char)
		return
	var _quick_node = get_quick_node()
	# Putting skin tweaks into memory so we can edit them
	if !_quick_node.skin_tweaks.has(powerup_name):
		# Finding a JSON file and importing stuff from it
		if SkinsManager.misc_textures.has(SkinsManager.current_skin) && SkinsManager.misc_textures[SkinsManager.current_skin].has("global_skin_tweaks"):
			_quick_node.skin_tweaks[powerup_name] = SkinsManager.misc_textures[SkinsManager.current_skin].global_skin_tweaks.duplicate(true)
		# If there's no JSON, loading defaults
		else:
			_quick_node.skin_tweaks[powerup_name] = CharacterManager.misc_textures[_char].global_skin_tweaks.duplicate(true)
	# Creating settings to configure skin tweaks right in the game
	var sorted_dict: Dictionary = CharacterManager.misc_textures[_char].global_skin_tweaks.duplicate(true)
	sorted_dict.sort()
	for tweak in sorted_dict:
		print(tweak)
		if tweak is Dictionary: continue
		create_tweak_selection(tweak)
	
	var _sfx = CharacterManager.get_sound_replace(selected_sound, SELECT_ENTER, "menu_enter", false)
	Audio.play_1d_sound(_sfx, true, { "ignore_pause": true, "bus": "1D Sound" })
	_select_category()
	
	move_to.set_meta("_powerup_name", powerup_name)
	var _label = move_to.get_child(0).get_child(0)
	if _label && _label is Label:
		if !_label.has_meta("orig_text"):
			_label.set_meta("orig_text", _label.text)
		_label.text = _label.get_meta("orig_text", "%s") % powerup_name.replacen("_", " ")
	
	move_to._update_selectors()
	move_to.move_selector.call_deferred(0, true)
	move_to.size.y = move_to.get_combined_minimum_size().y
	camera_2d.update_limit.call_deferred()
	get_quick_node()._resize_global_skin_tweaks()

func get_tweak_value(tweak) -> Variant:
	var _quick_node = get_quick_node()
	var _powerup = "global_skin_tweaks"
	if _quick_node.skin_tweaks.has(powerup_name) && _quick_node.skin_tweaks[powerup_name].has(tweak):
		return _quick_node.skin_tweaks[powerup_name][tweak]
	if SkinsManager.misc_textures.has(SkinsManager.current_skin) && SkinsManager.misc_textures[SkinsManager.current_skin].has(_powerup):
		return SkinsManager.misc_textures[SkinsManager.current_skin][_powerup][tweak]
	return CharacterManager.misc_textures[CharacterManager.get_character_name()][_powerup][tweak]

func create_tweak_selection(tweak) -> void:
	if get_tweak_value(tweak) is Dictionary: return
	super(tweak)
