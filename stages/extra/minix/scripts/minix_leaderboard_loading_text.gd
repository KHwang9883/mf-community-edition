extends Label

@onready var selector = $"../Selector"
@onready var lb = Scenes.current_scene.get_node("START/Leaderboard")
@onready var menu_items_controller: Control = $"../MenuItemsController"
@onready var start: Label = $"../CanvasLayer/Start"
@onready var start_2: Label = $"../CanvasLayer/Start2"


func _physics_process(_delta: float) -> void:
	
	text = "loading..." if lb.is_loading else "no results...\nbecome the first one!"
	if lb.old:
		text = "this game has been discontinued.\nplease download\nmario forever: community edition\nto use the leaderboard system!"
	elif lb.has_error:
		text = "failed to load the leaderboard!\nplease check your internet connection."
	selector.visible = lb.has_results
	menu_items_controller.control_forward = "ui_down" if lb.has_results else "ui_text_delete_all_to_right"
	menu_items_controller.control_backward = "ui_up" if lb.has_results else "ui_text_delete_all_to_right"
	start.visible = lb.has_results || lb.has_error
	start_2.visible = lb.has_results || lb.has_error
