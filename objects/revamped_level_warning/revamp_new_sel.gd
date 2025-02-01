extends MenuSelection

@export var is_new: bool = true

@onready var prog: Control = $"../.."
var _has_started: bool

func _handle_select(mouse_input: bool = false) -> void:
	if _has_started:
		return
	super(mouse_input)
	
	if is_new:
		prog.selected_new.emit()
	else:
		prog.selected_old.emit()
	print("[RevampMessage] Selected is new: " + str(is_new))
	prog.toggle(true)
	
	_has_started = true
	get_parent().focused = false
