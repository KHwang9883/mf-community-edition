extends "res://stages/main_menu/scripts/tweak_category_sel.gd"

#@export_multiline var tweak_description_text: String

#var toggle_sound = preload("res://engine/scenes/main_menu/sounds/change.wav")
#var skin_list: Array = [""]
#var skin_sel_index: int
#var _timer: float

#@onready var value: Label = $Value
#@onready var arrow_l: Label = $HBoxContainer/Value/arrow
#@onready var arrow_r: Label = $HBoxContainer/HBoxContainer/arrow

const SKIN_PACK_SELECTION = preload("res://stages/main_menu/objects/character_editor/skin_pack_selection.tscn")
@export_color_no_alpha var COLOR_SELECTED_SKIN := Color(1.0, 0.895, 0.79)

@onready var quick_settings_script: Node = $"../../SkinTweaks/HSeparatorSpawn/QuickSettingsScript"
@onready var h_separator_spawn_tweaks: HSeparator = $"../../SkinSelector/HSeparatorSpawnTweaks"

func _on_button_selection_entered() -> void:
	get_tree().call_group(&"_skin_selection", &"queue_free")
	
	set_skin_pack_none_color()
	
	var _arr := PackedStringArray(SkinsManager.custom_sprite_frames.keys())
	_arr.sort()
	for i in _arr.size():
		if _arr[i].is_empty(): continue
		if _arr[i].begins_with("."): continue
		if _arr[i] == "none": continue
		var _skin_sel: Control = SKIN_PACK_SELECTION.instantiate()
		var label: Label = _skin_sel.get_node("Label")
		label.text = "%s" % [_arr[i].replacen("_", " ")]
		
		_skin_sel.skin_id = _arr[i]
		if _arr[i] == SkinsManager.current_skin:
			label.add_theme_color_override(&"font_color", COLOR_SELECTED_SKIN)
		_skin_sel.add_to_group(&"_skin_selection")
		move_to.add_child(_skin_sel)
		move_to.move_child(_skin_sel, move_to.get_child_count() - 2)
		
	
	move_to._update_selectors()
	quick_settings_script._base_resize_menu(move_to)


func set_skin_pack_none_color() -> void:
	var skin_none_sel: Label = move_to.get_node("SkinPackNone/Label")
	if SkinsManager.current_skin.is_empty():
		skin_none_sel.add_theme_color_override(&"font_color", COLOR_SELECTED_SKIN)
	else:
		skin_none_sel.remove_theme_color_override(&"font_color")


func _on_exit_selection_entered() -> void:
	SettingsManager._process_settings()
	SkinsManager.load_external_textures()


#func _ready():
	#_update_string.call_deferred()
	#SkinsManager.skins_loaded.connect(_update_string)


#func _handle_focused(focus) -> void:
	#super(focus)
	#if !focus: return
	#if tweak_description_text:
		#$"../..".emit_signal(&"_tweak_desc", get_parent())


func _handle_select(mouse_input: bool = false) -> void:
	if !focused || !get_parent().focused: return
	_on_button_selection_entered()
	super(mouse_input)
	#if !focused || !get_parent().focused: return
	#var old_value = SettingsManager.settings.skin
	#
	#skin_sel_index = wrapi(skin_sel_index + 1, 0, skin_list.size())
	#SettingsManager.settings.skin = skin_list[skin_sel_index]
	#SkinsManager.current_skin = SettingsManager.settings.skin
	#_toggled_option(old_value, SettingsManager.settings.skin)
	#Scenes.current_scene.get_node("Window").visible = true

func _physics_process(delta: float) -> void:
	var par_focused: bool = get_parent().focused
	if focused && par_focused && get_window().has_focus() && Input.is_action_just_pressed(trigger_action):
		_handle_select(false)
	
	if focused && Input.is_action_just_pressed(&"ui_select") && par_focused && tweak_description_text:
		$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)
	
	if !valu:
		return
	if focused && !is_blocked:
		_timer += delta * 10
		valu.modulate.a = min((cos(_timer) / 2.5) + 0.6, 1.0)
		valu.remove_theme_color_override(&"font_color")
		_update_text()
	elif par_focused:
		valu.modulate.a = 1.0
		valu.text = SettingsManager.settings.skin
		if valu.text.is_empty():
			valu.text = "none"
		valu.add_theme_color_override(&"font_color", Color(0.8, 1.0, 0.9))
	#
	#arrow_r.visible = focused
	#arrow_l.visible = focused
	#
	#var old_value = SettingsManager.settings.skin
	#
	#if Input.is_action_just_pressed("ui_right"):
		#skin_sel_index = wrapi(skin_sel_index + 1, 0, skin_list.size())
		#SettingsManager.settings.skin = skin_list[skin_sel_index]
		#_toggled_option(old_value, SettingsManager.settings.skin)
	#elif Input.is_action_just_pressed("ui_left"):
		#skin_sel_index = wrapi(skin_sel_index - 1, 0, skin_list.size())
		#SettingsManager.settings.skin = skin_list[skin_sel_index]
		#_toggled_option(old_value, SettingsManager.settings.skin)


#func _toggled_option(old_val, new_val) -> void:
	#if old_val == new_val: return
	##var _sfx = CharacterManager.get_sound_replace(toggle_sound, toggle_sound, "menu_toggle", false)
	#Audio.play_1d_sound(toggle_sound, true, { "ignore_pause": true, "bus": "1D Sound" })
	#SettingsManager._process_settings()
	#SkinsManager.current_skin = SettingsManager.settings.skin
	#_update_string()


#func _update_string() -> void:
	#value.text = SettingsManager.settings.skin
	#if value.text.is_empty():
		#value.text = "none"
	#
	#skin_list = [""]
	#var skin_keys = SkinsManager.custom_sprite_frames.keys().duplicate()
	#if skin_keys.has("none"): skin_keys.erase("none")
	#skin_list.append_array(skin_keys)
	#var findings := clampi(int(skin_list.find(SettingsManager.settings.skin)), 0, 99)
	#skin_sel_index = findings
	#if skin_sel_index >= skin_list.size():
		#skin_sel_index = 0
	#prints(SkinsManager.current_skin, SettingsManager.settings.skin)


#func _handle_right_click() -> void:
	#if focused && tweak_description_text:
		#$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)
