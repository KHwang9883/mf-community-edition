extends MenuSelection

@export var cancel: bool = true

@onready var pause: Control = $"../.."
@onready var update_checker: Node = $"../../../../General/UpdateChecker"

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	if cancel:
		pause.toggle(false)
		return
	
	OS.shell_open(update_checker.url_open)
	OS.set_restart_on_exit(false)
	get_tree().quit()
