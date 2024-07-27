extends MenuSelection

@export var tweak_name: String
@export var default_value: bool

#var toggle_sound = preload("res://engine/scenes/main_menu/sounds/change.wav")
@onready var toggle: TextureRect = $Toggle

func _ready() -> void:
	var tweak = SettingsManager.get_tweak(tweak_name, default_value)
	toggle.texture.region.position.y = 0 if tweak else 16


func _handle_select() -> void:
	super()
	var tweak = SettingsManager.get_tweak(tweak_name, default_value)
	_handle_toggle(!tweak)


func _physics_process(delta: float) -> void:
	super(delta)
	if !focused: return
	
	if Input.is_action_just_pressed("ui_left"):
		_handle_toggle(false)
	elif Input.is_action_just_pressed("ui_right"):
		_handle_toggle(true)


func _handle_toggle(to_set: bool) -> void:
	var tweak = SettingsManager.get_tweak(tweak_name, default_value)
	if (to_set && !tweak) || (!to_set && tweak):
		SettingsManager.set_tweak(tweak_name, to_set)
		#Audio.play_1d_sound(toggle_sound, true, { "ignore_pause": true })
		toggle.texture.region.position.y = 0 if to_set else 16
