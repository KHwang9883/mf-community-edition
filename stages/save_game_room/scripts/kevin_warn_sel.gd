extends MenuSelection

@export var is_new: bool = true
@export var whatever: bool = false

@onready var prog: Control = $"../.."
var _has_started: bool

func _handle_select(mouse_input: bool = false) -> void:
	if _has_started:
		return
	super(mouse_input)
	
	if !whatever:
		SettingsManager.set_tweak("secret_mode_new_death_sounds", is_new)
		SettingsManager.save_tweaks()
		print("[RandomSoundsTweakMessage] Selected is enabled: " + str(is_new))
	
	prog.toggle(true)
	
	_has_started = true
	get_parent().focused = false
