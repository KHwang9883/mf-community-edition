extends MenuSelection

@export var tweak_name: String
@export var default_value: bool

var toggle_off = preload("res://sfx/tweak_off.mp3")
@onready var toggle: TextureRect = $Toggle

func _ready() -> void:
	var tweak = SettingsManager.get_tweak(tweak_name, default_value)
	toggle.texture.region.position.y = 0 if tweak else 16


func _handle_select() -> void:
	var tweak = SettingsManager.get_tweak(tweak_name, default_value)
	_handle_toggle(!tweak)
	if !tweak:
		super()
	else:
		Audio.play_1d_sound(toggle_off, true, { "ignore_pause": true, "bus": "1D Sound" })


func _physics_process(delta: float) -> void:
	super(delta)
	if !focused: return
	
	if Input.is_action_just_pressed("ui_left"):
		var _set: bool = _handle_toggle(false)
		if _set:
			Audio.play_1d_sound(toggle_off, true, { "ignore_pause": true, "bus": "1D Sound" })
	elif Input.is_action_just_pressed("ui_right"):
		var _set: bool = _handle_toggle(true)
		if _set:
			Audio.play_1d_sound(selected_sound, true, { "ignore_pause": true, "bus": "1D Sound" })


func _handle_toggle(to_set: bool) -> bool:
	var tweak = SettingsManager.get_tweak(tweak_name, default_value)
	if (to_set && !tweak) || (!to_set && tweak):
		SettingsManager.set_tweak(tweak_name, to_set)
		toggle.texture.region.position.y = 0 if to_set else 16
		return true
	return false
