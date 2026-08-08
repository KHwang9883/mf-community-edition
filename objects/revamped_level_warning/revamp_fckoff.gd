extends MenuSelection

@export var set_tweak_off: bool = true

@onready var prog: Control = $"../.."
var _has_started: bool

func _handle_select(mouse_input: bool = false) -> void:
	if _has_started:
		return
	super(mouse_input)
	
	var is_new = prog._remade_tweak
	
	if is_new:
		prog.selected_new.emit()
	else:
		prog.selected_old.emit()
	
	if set_tweak_off:
		if !prog._improved_levels:
			SettingsManager.set_tweak("show_warning_on_revamped_levels", false)
		else:
			SettingsManager.set_tweak("show_warning_on_improved_levels", false)
		SettingsManager.save_tweaks()
	
	print("[RevampMessage] Improv?: %s, Is New: %s, warning tweak turned off: %s" % [
		prog._improved_levels, is_new, set_tweak_off
	])
	prog.toggle(true)
	
	_has_started = true
