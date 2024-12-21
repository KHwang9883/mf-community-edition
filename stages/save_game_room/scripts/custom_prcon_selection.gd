extends "res://engine/components/progress_continue/scripts/continue_sel.gd"

@onready var progress_skipper: Node = Scenes.current_scene.get_node("Node")


func _handle_select(mouse_input: bool = false) -> void:
	if !!prog.profile.get("saved_profile_data").get("mario_forever_expert"):
		progress_skipper.mario_forever_advance()
		
	super(mouse_input)
	
	KevinGlobal.activated = !!prog.profile.get("saved_profile_data").get("kevin_mode_enabled")
	
