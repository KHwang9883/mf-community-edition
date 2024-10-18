extends MenuSelection

@onready var menu_items_controller: Control = $"../MenuItemsController"

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
