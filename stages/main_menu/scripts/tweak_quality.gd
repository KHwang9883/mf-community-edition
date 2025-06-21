extends MenuSelection

const STRING := [
	"classic",
	"modern",
	"modern + softendo"
]

var toggle_sound = preload("res://engine/scenes/main_menu/sounds/change.wav")
var value
@export_multiline var tweak_description_text: String
@onready var arrow_l: Label = $HBoxContainer/Value/arrow
@onready var arrow_r: Label = $HBoxContainer/HBoxContainer/arrow

func _ready():
	_update_string.call_deferred()
	SettingsManager.settings_updated.connect(_update_string)
	value = $HBoxContainer/Value


func _handle_select(mouse_input: bool = false) -> void:
	if !focused || !get_parent().focused: return
	var old_value = SettingsManager.settings.quality
	
	SettingsManager.settings.quality = wrapi(old_value + 1, 0, 3)
	_toggled_option(old_value, SettingsManager.settings.quality)


func _handle_focused(focus) -> void:
	super(focus)
	if !focus: return
	if tweak_description_text:
		$"../..".emit_signal(&"_tweak_desc", get_parent())


func _physics_process(delta: float) -> void:
	super(delta)
	if !get_parent().focused: return
	
	arrow_r.visible = focused
	arrow_l.visible = focused
	
	if !focused: return
	
	var old_value = SettingsManager.settings.quality
	if old_value == 0:
		arrow_l.visible = false
	elif old_value == 2:
		arrow_r.visible = false
	
	if Input.is_action_just_pressed("ui_right"):
		SettingsManager.settings.quality = clamp(old_value + 1, 0, 2)
		_toggled_option(old_value, SettingsManager.settings.quality)
	elif Input.is_action_just_pressed("ui_left"):
		SettingsManager.settings.quality = clamp(old_value - 1, 0, 2)
		_toggled_option(old_value, SettingsManager.settings.quality)
	elif Input.is_action_just_pressed(&"ui_select"):
		if tweak_description_text:
			$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)


func _toggled_option(old_val, new_val) -> void:
	if old_val == new_val: return
	var _sfx = CharacterManager.get_sound_replace(toggle_sound, toggle_sound, "menu_toggle", false)
	Audio.play_1d_sound(_sfx, true, { "ignore_pause": true, "bus": "1D Sound" })
	SettingsManager._process_settings()
	_update_string()


func _update_string() -> void:
	value.text = STRING[SettingsManager.settings.quality]
	

func _handle_right_click() -> void:
	if focused && tweak_description_text:
		$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)
