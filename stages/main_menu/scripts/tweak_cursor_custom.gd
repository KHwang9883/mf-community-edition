@tool
extends "res://stages/main_menu/scripts/tweak_boolean.gd"


func _handle_toggle(to_set: bool) -> bool:
	var out: bool = super(to_set)
	var _mouse_cursor = ProjectSettings.get_setting("application/thunder_settings/custom_mouse_cursor_path")
	if SettingsManager.get_tweak(tweak_name, false):
		Input.set_custom_mouse_cursor(load(_mouse_cursor))
	else:
		Input.set_custom_mouse_cursor(null)
	return out
