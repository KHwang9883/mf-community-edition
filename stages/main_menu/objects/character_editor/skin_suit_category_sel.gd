extends "res://stages/main_menu/scripts/tweak_category_sel.gd"

const BOOL_SUIT_TWEAK_SELECTION = preload("res://stages/main_menu/objects/character_editor/bool_suit_tweak_selection.tscn")
const FLOAT_SUIT_TWEAK_SELECTION = preload("res://stages/main_menu/objects/character_editor/float_suit_tweak_selection.tscn")
const SUBMENU_TWEAK_SELECTION = preload("res://stages/main_menu/objects/character_editor/submenu_tweak_selection.tscn")

var tweak_descriptions: Dictionary = {
	"look_up_animation": "'look_up' & 'hold_look_up' animations: triggered by pressing up button.\n\nwill also make a sound, if it exists.",
	"attack_air_animation": "'attack_air' animation: shooting a projectile in mid-air plays this unique animation.\n\nfor suits without attacking, this has no effect.",
	"separate_run_animation": "'p_run', 'p_jump', 'p_fall' animations: running at max speed triggers these animations.\n\nfor suits without constant running ability, this has no effect.",
	"idle_animation": "'idle' animation: when no input is made, this animation plays after a specified amount of time.",
	"idle_activate_after_sec": {
		"name" = "from 0.1 to 9999; no effect if idle animation is disabled.",
		"min" = 0.1,
		"max" = 9999.0,
		"step" = 0.1,
	},
	#"stomp_animation": false, # after stomping an enemy or jumping on springboard
	"kick_ground_animation": "the 'kick' animation also plays when kicking things without holding anything (e.g. shells).",
	"warp_animation": "'warp' animation; if false, warping vertically will use 'jump', and 'crouch' or 'default'.",
	"skid_sound_loop_delay": {
		"name" = 'delay in seconds between each playback of the skidding sound; from 0.05 to 2.0.',
		"min" = 0.05,
		"max" = 2.0,
		"step" = 0.01,
	},
	"head_bump_sound": "play global sound 'head_bump' on every touch of ceiling.",
	"fall_animation": "if false, 'fall' animation and the derivatives are replaced by 'jump'.",
	"separate_swim_idle_animation": "if looping for 'swim' animation is disabled, the 'swim_idle' animation will play right after.",
	"emit_particles": {
		"enabled": "if no texture is set, the default texture will be starman particles.",
		"color": "particles will be modulated by this color.",
		"show_behind": "'show_behind_parent': particles will be rendered behind the player.",
		"lifetime_sec": {
			"name" = "from 0.04 to 600; the more the value, the less frequently new particles will be generated.",
			"min" = 0.04,
			"max" = 600,
			"step" = 0.1,
		},
		"amount_ratio": {
			"name" = "from 0 to 1.0; the maximum particle amount is 48, and this tweak multiplies it.",
			"min" = 0.0,
			"max" = 1.0,
			"step" = 0.01,
		},
		"local_coords": "should the particles follow player's position? also if true, may fix jitter on movement.",
		"offset": "offset particles by this Vector2. (x, y)"
	},
	"emit_particles_sel": "particles for in-game character; for more options, see global skin tweaks menu.",
	"loop_frame_offsets_sel": "add any animation to the list to set a frame where the animation will continue after looping; 0-based. negative values are ignored.",
	
	
}

@export var powerup_name: String

var h_separator_spawn: HSeparator

func _ready() -> void:
	h_separator_spawn = $"../../SkinSuitSettings/HSeparatorSpawnTweaks"
	super()

func _physics_process(delta: float) -> void:
	super(delta)
	if !get_parent().focused: return
	if !powerup_name == "_all_suits": return
	if SkinsManager.current_skin.is_empty():
		modulate.v = 1.0
		is_blocked = false
	else:
		is_blocked = true
		modulate.v = 0.5
	

func _handle_select(mouse_input: bool = false) -> void:
	#if Data.technical_values.get("main_menu_scene"): return
	if !SkinsManager.current_skin.is_empty() && powerup_name == "_all_suits":
		var _sfx = CharacterManager.get_sound_replace(SELECT_FAILURE, SELECT_FAILURE, "menu_failure", false)
		Audio.play_1d_sound(_sfx, true, { "ignore_pause": true, "bus": "1D Sound" })
		return
	# Custom skin
	if SkinsManager.current_skin && SkinsManager.custom_textures.has(SkinsManager.current_skin):
		get_tree().call_group(&"_skin_suit_tweak", &"queue_free")
		var _char = CharacterManager.get_character_name()
		if !CharacterManager.suit_tweaks.has(_char):
			print("Warning: No suit tweaks for char: ", _char)
		elif CharacterManager.suit_tweaks[_char].has(powerup_name):
			var _quick_node = get_quick_node()
			# Засовываем скин твики в память, чтоб там ее редачить
			if !_quick_node.skin_tweaks.has(powerup_name):
				# Ищем в файле жсон и берем оттуда
				if SkinsManager.suit_tweaks.has(SkinsManager.current_skin) && SkinsManager.suit_tweaks[SkinsManager.current_skin].has(powerup_name):
					_quick_node.skin_tweaks[powerup_name] = SkinsManager.suit_tweaks[SkinsManager.current_skin][powerup_name].duplicate(true)
				# Если в жсоне нет, берем дефолтные
				else:
					_quick_node.skin_tweaks[powerup_name] = CharacterManager.suit_tweaks[_char][powerup_name].duplicate(true)
			# Создаем опции для настройки скин твиков прямо из игры
			for tweak in CharacterManager.suit_tweaks[_char][powerup_name]:
				create_tweak_selection(tweak)
	
	# Default skin (none)
	elif SkinsManager.current_skin.is_empty() && powerup_name == "_all_suits":
		get_tree().call_group(&"_skin_suit_tweak", &"queue_free")
		var _char = CharacterManager.get_character_name()
		if !CharacterManager.suit_tweaks.has(_char):
			print("Warning: No suit tweaks for char: ", _char)
		elif CharacterManager.suit_tweaks[_char].has("super"):
			var _quick_node = get_quick_node()
			if !_quick_node.skin_tweaks.has(powerup_name):
				if SkinsManager.suit_tweaks.has("none") && SkinsManager.suit_tweaks["none"].has("super"):
					_quick_node.skin_tweaks[powerup_name] = SkinsManager.suit_tweaks["none"]["super"].duplicate(true)
				else:
					_quick_node.skin_tweaks[powerup_name] = CharacterManager.suit_tweaks[_char]["super"].duplicate(true)
			for tweak in CharacterManager.suit_tweaks[_char]["super"]:
				if !tweak in [
					"warp_animation", "head_bump_sound", "attack_air_animation", "kick_ground_animation"
				]: continue
				create_tweak_selection(tweak)
		
	super(mouse_input)
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
	get_quick_node()._resize_skin_suit()
	#print(move_to.selectors)

func get_quick_node() -> Node:
	return Scenes.current_scene.get_node("Tweaks/SubViewportContainer/SubViewport/Tweaks/SkinTweaks/HSeparatorSpawn/QuickSettingsScript")

func get_tweak_value(tweak) -> Variant:
	var _quick_node = get_quick_node()
	if _quick_node.skin_tweaks.has(powerup_name) && _quick_node.skin_tweaks[powerup_name].has(tweak):
		return _quick_node.skin_tweaks[powerup_name][tweak]
	if SkinsManager.suit_tweaks.has(SkinsManager.current_skin) && SkinsManager.suit_tweaks[SkinsManager.current_skin].has(powerup_name):
		return SkinsManager.suit_tweaks[SkinsManager.current_skin][powerup_name][tweak]
	return CharacterManager.suit_tweaks[CharacterManager.get_character_name()][powerup_name][tweak]

func create_tweak_selection(tweak) -> void:
	#prints(tweak, get_tweak_value(tweak))
	# Булеан, чекмарк
	if get_tweak_value(tweak) is bool:
		var _bool_tweak = BOOL_SUIT_TWEAK_SELECTION.instantiate()
		_bool_tweak.get_node("Label").text = tweak.replacen("_", " ")
		_bool_tweak.tweak_name = tweak
		_bool_tweak.is_toggled = get_tweak_value(tweak)
		if tweak in tweak_descriptions:
			_bool_tweak.tweak_description_text = tweak_descriptions[tweak]
		move_to.add_child(_bool_tweak)
		print(move_to)
		Thunder.reorder_on_top_of(_bool_tweak, h_separator_spawn)
	# Число, окно со спинбоксом
	elif get_tweak_value(tweak) is float:
		_create_spinbox_selection(tweak, false)
		
	# То же
	elif get_tweak_value(tweak) is int:
		_create_spinbox_selection(tweak, true)
	# Сабменю
	elif get_tweak_value(tweak) is Dictionary:
		var _submenu = SUBMENU_TWEAK_SELECTION.instantiate()
		_submenu.get_node("Label").text = tweak.replacen("_", " ")
		_submenu.tweak_name = tweak
		_submenu.powerup_name = powerup_name
		if tweak in tweak_descriptions && tweak_descriptions[tweak] is Dictionary:
			_submenu.tweak_descriptions = tweak_descriptions[tweak]
		if tweak + "_sel" in tweak_descriptions:
			_submenu.tweak_description_text = tweak_descriptions[tweak + "_sel"]
		move_to.add_child(_submenu)
		Thunder.reorder_on_top_of(_submenu, h_separator_spawn)


func _create_spinbox_selection(tweak, is_int: bool) -> Node:
	var _float_tweak = FLOAT_SUIT_TWEAK_SELECTION.instantiate()
	_float_tweak.get_node("Label").text = tweak.replacen("_", " ")
	_float_tweak.get_node("Label2").text = str(get_tweak_value(tweak))
	_float_tweak.tweak_name = tweak
	if is_int:
		_float_tweak.get_node("Window/SpinBox").step = 1
	if tweak in tweak_descriptions:
		if tweak_descriptions[tweak] is String:
			_float_tweak.tweak_description_text = tweak_descriptions[tweak]
		else:
			_float_tweak.tweak_description_text = tweak_descriptions[tweak].name
			var spinbox: SpinBox = _float_tweak.get_node("Window/SpinBox")
			if "min" in tweak_descriptions[tweak]:
				spinbox.min_value = tweak_descriptions[tweak].min
			if "max" in tweak_descriptions[tweak]:
				spinbox.max_value = tweak_descriptions[tweak].max
			if "step" in tweak_descriptions[tweak]:
				spinbox.custom_arrow_step = tweak_descriptions[tweak].step
	move_to.add_child(_float_tweak)
	Thunder.reorder_on_top_of(_float_tweak, h_separator_spawn)
	return _float_tweak
