extends "res://engine/components/progress_continue/scripts/continue_sel.gd"

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	
	KevinGlobal.activated = !!prog.profile.get("saved_profile_data").get("kevin_mode_enabled")
	
