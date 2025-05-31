extends MenuSelection

@onready var mid_level_item_store: Control = $"../../.."

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	mid_level_item_store.selected(self)
