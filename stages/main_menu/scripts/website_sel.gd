extends MenuSelection

@export var link: String

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	OS.shell_open(link)
