extends MenuSelection

@export_node_path("AnimatableBody2D") var message_block_path: NodePath = ^"../../MessageBlock"
@onready var message_block: AnimatableBody2D = get_node(message_block_path)

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	message_block.show_message()
