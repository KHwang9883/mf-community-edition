extends MenuSelection

@export var gameover = false
@onready var parent: MenuItemsController = get_parent()

func _handle_select() -> void:
	super()
	parent.focused = false
	
	var lb = Scenes.current_scene.get_node("START/Leaderboard")
	lb.visible = true
	lb.menu_controller.focused = true
	lb.menu_controller.go_back_to = get_path()
	
	var lbb = Scenes.current_scene.get_node("START/Leaderboard/SubViewportContainer/SubViewport/Control/MenuItemsController")
	lbb.gameover = gameover
	
	lb._load_records()
	Pause.get_child(0).open_blocked = true

