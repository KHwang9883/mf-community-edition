extends MenuSelection

@export var is_docs: bool = false
@export_multiline var tweak_description_text: String

@onready var valu = get_node_or_null(^"Value")
var _timer: float

func _physics_process(delta: float) -> void:
	super(delta)
	if focused && get_parent().focused:
		if Input.is_action_just_pressed(&"ui_select") && tweak_description_text:
			$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)
	
	if !valu:
		return
	if focused:
		_timer += delta * 10
		valu.modulate.a = min((cos(_timer) / 2.5) + 0.6, 1.0)
	else:
		valu.modulate.a = 0.0

func _handle_focused(focus) -> void:
	super(focus)
	if !focus: return
	if tweak_description_text:
		$"../..".emit_signal(&"_tweak_desc", get_parent())

func _handle_right_click() -> void:
	if focused && get_parent().focused && tweak_description_text:
		$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)

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
	
