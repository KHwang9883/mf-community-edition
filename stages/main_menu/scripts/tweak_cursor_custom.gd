@tool
extends "res://stages/main_menu/scripts/tweak_boolean.gd"


func _handle_toggle(to_set: bool) -> bool:
	var out: bool = super(to_set)
	SettingsManager.apply_custom_mouse_cursor()
	return out
