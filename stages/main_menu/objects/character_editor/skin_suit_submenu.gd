extends "res://stages/main_menu/scripts/tweak_category_sel.gd"

const BOOL_SUIT_TWEAK_SELECTION = preload("res://stages/main_menu/objects/character_editor/bool_suit_tweak_selection.tscn")
const FLOAT_SUIT_TWEAK_SELECTION = preload("res://stages/main_menu/objects/character_editor/float_suit_tweak_selection.tscn")
const COLOR_SUIT_TWEAK_SELECTION = preload("res://stages/main_menu/objects/character_editor/color_suit_tweak_selection.tscn")
const VECTOR2_SUIT_TWEAK_SELECTION = preload("res://stages/main_menu/objects/character_editor/vector2_suit_tweak_selection.tscn")

var tweak_descriptions: Dictionary = {}
var powerup_name: String
var tweak_name: String

@onready var h_separator_spawn: HSeparator = $"../../SkinSuitSettingsSubmenu/HSeparatorSpawnTweaks"

func _handle_select(mouse_input: bool = false) -> void:
	# Custom skin
	if SkinsManager.current_skin:
		var skin_tweaks = SkinsManager.suit_tweaks if powerup_name != "global" else SkinsManager.misc_textures
		var _powerup = powerup_name if powerup_name != "global" else "global_skin_tweaks"
		var _default_tweaks = CharacterManager.suit_tweaks if powerup_name != "global" else CharacterManager.misc_textures
		get_tree().call_group(&"_submenu_skin_suit_tweak", &"queue_free")
		var _char = CharacterManager.get_character_name()
		if !_default_tweaks.has(_char):
			print("Warning: No suit tweaks for char: ", _char)
		elif _default_tweaks[_char].has(_powerup) && _default_tweaks[_char][_powerup].has(tweak_name):
			var _quick_node = get_quick_node()
			# Putting skin tweaks into memory so we can edit them
			if !_quick_node.skin_tweaks.has(powerup_name):
				# Finding a JSON file and importing stuff from it
				if skin_tweaks.has(SkinsManager.current_skin) && skin_tweaks[SkinsManager.current_skin].has(_powerup) && skin_tweaks[SkinsManager.current_skin][_powerup].has(tweak_name):
					_quick_node.skin_tweaks[powerup_name] = skin_tweaks[SkinsManager.current_skin][_powerup][tweak_name].duplicate(true)
				# If there's no JSON, loading defaults
				else:
					_quick_node.skin_tweaks[powerup_name] = _default_tweaks[_char][_powerup][tweak_name].duplicate(true)
			# Creating settings to configure skin tweaks right in the game
			for tweak in _default_tweaks[_char][_powerup][tweak_name]:
				create_tweak_selection(tweak)
		
	super(mouse_input)
	move_to.set_meta("_powerup_name", powerup_name)
	move_to.set_meta("_submenu_name", tweak_name)
	var _label = move_to.get_child(0).get_child(0)
	if _label && _label is Label:
		if !_label.has_meta("orig_text"):
			_label.set_meta("orig_text", _label.text)
		_label.text = _label.get_meta("orig_text", "%s\n%s") % [
			powerup_name.replacen("_", " "),
			tweak_name.replacen("_", " ")
		]
	
	move_to._update_selectors()
	move_to.move_selector.call_deferred(0, true)
	move_to.size.y = move_to.get_combined_minimum_size().y
	camera_2d.update_limit.call_deferred()
	get_quick_node()._resize_submenu()
	#print(move_to.selectors)

func get_quick_node() -> Node:
	return Scenes.current_scene.get_node("Tweaks/SubViewportContainer/SubViewport/Tweaks/SkinTweaks/HSeparatorSpawn/QuickSettingsScript")

func get_tweak_value(tweak) -> Variant:
	var _quick_node = get_quick_node()
	if _quick_node.skin_tweaks.has(powerup_name) && _quick_node.skin_tweaks[powerup_name].has(tweak_name) && _quick_node.skin_tweaks[powerup_name][tweak_name].has(tweak):
		return _quick_node.skin_tweaks[powerup_name][tweak_name][tweak]
	var skin_tweaks = SkinsManager.suit_tweaks if powerup_name != "global" else CharacterManager.misc_textures
	var _powerup = powerup_name if powerup_name != "global" else "global_skin_tweaks"
	if skin_tweaks.has(SkinsManager.current_skin) && skin_tweaks[SkinsManager.current_skin].has(_powerup) && skin_tweaks[SkinsManager.current_skin][_powerup].has(tweak_name):
		return skin_tweaks[SkinsManager.current_skin][_powerup][tweak_name][tweak]
	if powerup_name == "global":
		return CharacterManager.misc_textures[CharacterManager.get_character_name()][_powerup][tweak_name][tweak]
	return CharacterManager.suit_tweaks[CharacterManager.get_character_name()][powerup_name][tweak_name][tweak]

func create_tweak_selection(tweak) -> void:
	# Boolean, checkbox
	if get_tweak_value(tweak) is bool:
		var _bool_tweak = BOOL_SUIT_TWEAK_SELECTION.instantiate()
		_bool_tweak.get_node("Label").text = tweak.replacen("_", " ")
		_bool_tweak.tweak_name = tweak
		_bool_tweak.is_toggled = get_tweak_value(tweak)
		_bool_tweak.add_to_group(&"_submenu_skin_suit_tweak")
		if tweak in tweak_descriptions:
			_bool_tweak.tweak_description_text = tweak_descriptions[tweak]
		move_to.add_child(_bool_tweak)
		Thunder.reorder_on_top_of(_bool_tweak, h_separator_spawn)
	# A number, window with a spinbox
	elif get_tweak_value(tweak) is float && tweak_name != "loop_frame_offsets":
		var _float_tweak = FLOAT_SUIT_TWEAK_SELECTION.instantiate()
		_float_tweak.get_node("Label").text = tweak.replacen("_", " ")
		_float_tweak.get_node("Label2").text = str(get_tweak_value(tweak))
		_float_tweak.tweak_name = tweak
		_float_tweak.add_to_group(&"_submenu_skin_suit_tweak")
		move_to.add_child(_float_tweak)
		if tweak in tweak_descriptions:
			if tweak_descriptions[tweak] is String:
				_float_tweak.tweak_description_text = tweak_descriptions[tweak]
			else:
				_float_tweak.tweak_description_text = tweak_descriptions[tweak].name
				if "min" in tweak_descriptions[tweak]:
					_float_tweak.spin_box.min_value = tweak_descriptions[tweak].min
				if "max" in tweak_descriptions[tweak]:
					_float_tweak.spin_box.max_value = tweak_descriptions[tweak].max
				if "step" in tweak_descriptions[tweak]:
					_float_tweak.spin_box.custom_arrow_step = tweak_descriptions[tweak].step
		Thunder.reorder_on_top_of(_float_tweak, h_separator_spawn)
	# Same thing here
	elif get_tweak_value(tweak) is int || (get_tweak_value(tweak) is float && tweak_name == "loop_frame_offsets"):
		var _float_tweak = FLOAT_SUIT_TWEAK_SELECTION.instantiate()
		_float_tweak.get_node("Label").text = tweak.replacen("_", " ")
		_float_tweak.get_node("Label2").text = str(int(get_tweak_value(tweak)))
		_float_tweak.tweak_name = tweak
		_float_tweak.add_to_group(&"_submenu_skin_suit_tweak")
		move_to.add_child(_float_tweak)
		if _float_tweak.get(&"spin_box"):
			_float_tweak.spin_box.step = 1
			_float_tweak.spin_box.min_value = -1
			_float_tweak.spin_box.custom_arrow_step = 1
		if tweak in tweak_descriptions:
			if tweak_descriptions[tweak] is String:
				_float_tweak.tweak_description_text = tweak_descriptions[tweak]
			else:
				_float_tweak.tweak_description_text = tweak_descriptions[tweak].name
				if "min" in tweak_descriptions[tweak]:
					_float_tweak.spin_box.min_value = tweak_descriptions[tweak].min
				if "max" in tweak_descriptions[tweak]:
					_float_tweak.spin_box.max_value = tweak_descriptions[tweak].max
				if "step" in tweak_descriptions[tweak]:
					_float_tweak.spin_box.custom_arrow_step = tweak_descriptions[tweak].step
		Thunder.reorder_on_top_of(_float_tweak, h_separator_spawn)
	# Color picker
	elif get_tweak_value(tweak) is String && get_tweak_value(tweak).is_valid_html_color():
		var _color_tweak = COLOR_SUIT_TWEAK_SELECTION.instantiate()
		_color_tweak.get_node("Label").text = tweak.replacen("_", " ")
		_color_tweak.tweak_name = tweak
		_color_tweak.add_to_group(&"_submenu_skin_suit_tweak")
		if tweak in tweak_descriptions:
			_color_tweak.tweak_description_text = tweak_descriptions[tweak]
		move_to.add_child(_color_tweak)
		_color_tweak.color_rect.color = str(get_tweak_value(tweak))
		Thunder.reorder_on_top_of(_color_tweak, h_separator_spawn)
	# Vector2, window with 2 spinboxes
	elif _is_vector2_tweak(get_tweak_value(tweak)):
		var _vec_tweak = VECTOR2_SUIT_TWEAK_SELECTION.instantiate()
		var _vec := _to_vector2(get_tweak_value(tweak))
		_vec_tweak.get_node("Label").text = tweak.replacen("_", " ")
		_vec_tweak.tweak_name = tweak
		_vec_tweak.current_vec = _vec
		_vec_tweak.add_to_group(&"_submenu_skin_suit_tweak")
		move_to.add_child(_vec_tweak)
		if tweak in tweak_descriptions:
			if tweak_descriptions[tweak] is String:
				_vec_tweak.tweak_description_text = tweak_descriptions[tweak]
			else:
				_vec_tweak.tweak_description_text = tweak_descriptions[tweak].name
				_apply_vector2_spinbox_limits(_vec_tweak, tweak_descriptions[tweak])
		_vec_tweak.get_node("Label2").text = _vec_tweak.format_vec2(_vec)
		Thunder.reorder_on_top_of(_vec_tweak, h_separator_spawn)
	else:
		print(":( dont know how to parse %s" % tweak)


func _is_vector2_tweak(value: Variant) -> bool:
	if value is Vector2 || value is Vector2i:
		return true
	if value is Array && value.size() == 2:
		return typeof(value[0]) in [TYPE_INT, TYPE_FLOAT] && typeof(value[1]) in [TYPE_INT, TYPE_FLOAT]
	return false


func _to_vector2(value: Variant) -> Vector2:
	if value is Vector2:
		return value
	if value is Vector2i:
		return Vector2(value)
	if value is Array && value.size() >= 2:
		return Vector2(value[0], value[1])
	return Vector2.ZERO


func _apply_vector2_spinbox_limits(vec_tweak: Node, desc: Dictionary) -> void:
	for spin_box in [vec_tweak.spin_box_x, vec_tweak.spin_box_y]:
		if "min" in desc:
			spin_box.min_value = desc.min
		if "max" in desc:
			spin_box.max_value = desc.max
		if "step" in desc:
			spin_box.step = desc.step
			spin_box.custom_arrow_step = desc.step
