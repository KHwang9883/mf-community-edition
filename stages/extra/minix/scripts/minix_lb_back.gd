extends MenuSelection

@onready var menu_items_controller: Control = $"../MenuItemsController"

func _handle_select() -> void:
	super()
	print(menu_items_controller.get_node(menu_items_controller.go_back_to))
