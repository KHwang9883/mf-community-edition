extends MenuSelection

@export var is_docs: bool = false

@onready var valu = get_node_or_null(^"Value")
var _timer: float

func _physics_process(delta: float) -> void:
	super(delta)
	if !valu:
		return
	if focused:
		_timer += delta * 10
		valu.modulate.a = min((cos(_timer) / 2.5) + 0.6, 1.0)
	else:
		valu.modulate.a = 0.0

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	if is_docs:
		OS.shell_open("https://gist.github.com/jue131/e425619bc898df9feaa56cde6588216e")
		return
	
	var _dir := SkinsManager.base_dir
	if !DirAccess.dir_exists_absolute(_dir):
		DirAccess.make_dir_absolute(_dir)
	if SkinsManager.current_skin && DirAccess.dir_exists_absolute(_dir.path_join(SkinsManager.current_skin)):
		OS.shell_open(_dir.path_join(SkinsManager.current_skin))
	else:
		OS.shell_open(_dir)
	
