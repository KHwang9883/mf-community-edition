extends MenuSelection

@export var tweak_name: String
@export var default_value: bool
@export_multiline var tweak_description: String

var toggle_off = preload("res://sfx/tweak_off.mp3")
@onready var toggle: TextureRect = $Toggle

var is_blocked: bool
var is_toggled: bool

func _ready() -> void:
	toggle.texture.region.position.y = 0 if is_toggled else 16
	

func _handle_focused(focus) -> void:
	super(focus)
	if !focus: return
	if tweak_description:
		$"../..".emit_signal(&"_tweak_desc", get_parent())


func _handle_select(mouse_input: bool = false) -> void:
	if is_blocked: return
	
	#var tweak = SettingsManager.get_tweak(tweak_name, default_value)
	_handle_toggle(!is_toggled)
	if !is_toggled:
		super(mouse_input)
	else:
		Audio.play_1d_sound(toggle_off, true, { "ignore_pause": true, "bus": "1D Sound" })


func _physics_process(delta: float) -> void:
	super(delta)
	if !focused || !get_parent().focused: return
	
	if Input.is_action_just_pressed("ui_left"):
		var _set: bool = _handle_toggle(false)
		if _set:
			Audio.play_1d_sound(toggle_off, true, { "ignore_pause": true, "bus": "1D Sound" })
	elif Input.is_action_just_pressed("ui_right"):
		var _set: bool = _handle_toggle(true)
		if _set:
			Audio.play_1d_sound(selected_sound, true, { "ignore_pause": true, "bus": "1D Sound" })
	elif Input.is_action_just_pressed(&"ui_select"):
		if tweak_description:
			$"../..".emit_signal(&"_show_desc", tweak_description, $Label.text)


func _handle_toggle(to_set: bool) -> bool:
	if is_blocked:
		return false
	if (to_set && !is_toggled) || (!to_set && is_toggled):
		is_toggled = to_set
		toggle.texture.region.position.y = 0 if to_set else 16
		return true
	return false

func _handle_right_click() -> void:
	if focused && tweak_description:
		$"../..".emit_signal(&"_show_desc", tweak_description, $Label.text)
