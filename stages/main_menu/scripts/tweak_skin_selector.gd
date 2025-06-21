extends MenuSelection

@export_multiline var tweak_description_text: String

var toggle_sound = preload("res://engine/scenes/main_menu/sounds/change.wav")
var skin_list: Array = [""]
var skin_sel_index: int

@onready var value: Label = $HBoxContainer/Value
@onready var arrow_l: Label = $HBoxContainer/Value/arrow
@onready var arrow_r: Label = $HBoxContainer/HBoxContainer/arrow

func _ready():
	_update_string.call_deferred()
	SkinsManager.skins_loaded.connect(_update_string)


func _handle_focused(focus) -> void:
	super(focus)
	if !focus: return
	if tweak_description_text:
		$"../..".emit_signal(&"_tweak_desc", get_parent())


func _handle_select(mouse_input: bool = false) -> void:
	#super(mouse_input)
	if !focused || !get_parent().focused: return
	var old_value = SettingsManager.settings.skin
	
	skin_sel_index = wrapi(skin_sel_index + 1, 0, skin_list.size())
	SettingsManager.settings.skin = skin_list[skin_sel_index]
	SkinsManager.current_skin = SettingsManager.settings.skin
	_toggled_option(old_value, SettingsManager.settings.skin)
	#Scenes.current_scene.get_node("Window").visible = true


func _physics_process(delta: float) -> void:
	super(delta)
	
	arrow_r.visible = focused
	arrow_l.visible = focused
	
	if !get_parent().focused: return
	
	if !focused: return
	
	var old_value = SettingsManager.settings.skin
	
	if Input.is_action_just_pressed("ui_right"):
		skin_sel_index = wrapi(skin_sel_index + 1, 0, skin_list.size())
		SettingsManager.settings.skin = skin_list[skin_sel_index]
		_toggled_option(old_value, SettingsManager.settings.skin)
	elif Input.is_action_just_pressed("ui_left"):
		skin_sel_index = wrapi(skin_sel_index - 1, 0, skin_list.size())
		SettingsManager.settings.skin = skin_list[skin_sel_index]
		_toggled_option(old_value, SettingsManager.settings.skin)
	elif Input.is_action_just_pressed(&"ui_select"):
		if tweak_description_text:
			$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)


func _toggled_option(old_val, new_val) -> void:
	if old_val == new_val: return
	#var _sfx = CharacterManager.get_sound_replace(toggle_sound, toggle_sound, "menu_toggle", false)
	Audio.play_1d_sound(toggle_sound, true, { "ignore_pause": true, "bus": "1D Sound" })
	SettingsManager._process_settings()
	SkinsManager.current_skin = SettingsManager.settings.skin
	_update_string()


func _update_string() -> void:
	value.text = SettingsManager.settings.skin
	if value.text.is_empty():
		value.text = "none"
	
	skin_list = [""]
	var skin_keys = SkinsManager.custom_sprite_frames.keys().duplicate()
	if skin_keys.has("none"): skin_keys.erase("none")
	skin_list.append_array(skin_keys)
	var findings := clampi(int(skin_list.find(SettingsManager.settings.skin)), 0, 99)
	skin_sel_index = findings
	if skin_sel_index >= skin_list.size():
		skin_sel_index = 0
	prints(SkinsManager.current_skin, SettingsManager.settings.skin)


func _handle_right_click() -> void:
	if focused && tweak_description_text:
		$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)
