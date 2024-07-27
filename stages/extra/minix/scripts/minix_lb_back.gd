extends MenuSelection

@onready var menu_items_controller: Control = $"../MenuItemsController"

func _handle_select() -> void:
	super()
