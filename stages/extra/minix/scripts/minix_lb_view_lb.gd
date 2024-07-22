extends MenuSelection

@onready var parent: MenuItemsController = get_parent()

func _handle_select() -> void:
	super()
	parent.focused = false
	var lb = Scenes.current_scene.get_node("START/Leaderboard")
	lb.visible = true
	lb.menu_controller.focused = true
	lb.menu_controller.go_back_to = get_path()

