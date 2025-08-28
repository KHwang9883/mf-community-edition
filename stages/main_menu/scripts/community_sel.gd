extends MenuSelection

@export var link: String

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	get_parent().focused = false
	var modal = Scenes.current_scene.get_node_or_null("CommunityModal")
	if !modal: return
	var control = modal.get_node("Control")
	control.visible = true
	control.get_node("AnimationPlayer").play("fade")
	control.get_node("VBoxContainer").move_selector(0, true)
	await get_tree().physics_frame
	control.get_node("VBoxContainer").focused = true
