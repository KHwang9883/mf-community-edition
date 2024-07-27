extends MenuSelection

@export var link: String

func _handle_select() -> void:
	super()
	OS.shell_open(link)
