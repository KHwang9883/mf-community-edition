extends MenuSelection

@export var cancel: bool = true
@export_node_path("Node") var update_checker_path = ^"../../../../General/UpdateChecker"

@onready var pause: Control = $"../.."
@onready var update_checker: Node = get_node_or_null(update_checker_path)

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	if cancel:
		pause.toggle(false)
		Data.technical_values.skip_update_check = true
		return
	
	OS.shell_open(update_checker.url_open)
	OS.set_restart_on_exit(false)
	get_tree().quit()
