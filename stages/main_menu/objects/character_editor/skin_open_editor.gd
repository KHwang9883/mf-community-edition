extends MenuSelection

@export_multiline var tweak_description_text: String
@onready var valu = get_node_or_null(^"Value")
var _timer: float
@onready var skin_room: CanvasLayer = $"../../SkinRoom"

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
	
	const pck_arg = "--main-pack mfce-skin-editor.pck"
	var args = OS.get_cmdline_args()
	args.append(pck_arg)
	OS.set_restart_on_exit(true, args)
	get_tree().quit()
