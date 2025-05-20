extends MenuSelection

@onready var message_block: AnimatableBody2D = $"../../MessageBlock"

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	message_block.show_message()
