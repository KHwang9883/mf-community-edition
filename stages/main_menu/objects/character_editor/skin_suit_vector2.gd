extends MenuSelection

@export var tweak_name: String
@export_multiline var tweak_description_text: String

var is_blocked: bool
var cooldown: float = 0
var current_vec: Vector2

@onready var spin_box_x: SpinBox = $Window/VBoxContainer/HBoxX/SpinBoxX
@onready var spin_box_y: SpinBox = $Window/VBoxContainer/HBoxY/SpinBoxY


func _ready() -> void:
	var line_x := spin_box_x.get_line_edit()
	var line_y := spin_box_y.get_line_edit()
	var button_ok := $Window/HBoxContainer/ButtonOK
	var button_cancel := $Window/HBoxContainer/ButtonCancel
	line_x.focus_next = line_y.get_path()
	line_x.focus_neighbor_bottom = line_y.get_path()
	line_x.focus_previous = button_cancel.get_path()
	line_y.focus_previous = line_x.get_path()
	line_y.focus_neighbor_top = line_x.get_path()
	line_y.focus_next = button_ok.get_path()
	line_y.focus_neighbor_bottom = button_ok.get_path()


func _handle_focused(focus) -> void:
	super(focus)
	if !focus: return
	if tweak_description_text:
		$"../..".emit_signal(&"_tweak_desc", get_parent())


func _handle_select(mouse_input: bool = false) -> void:
	if is_blocked: return
	if cooldown > 0.0: return
	
	spin_box_x.value = current_vec.x
	spin_box_y.value = current_vec.y
	cooldown = 0.1
	$Window.visible = true
	get_tree().paused = true
	super(mouse_input)


func _physics_process(delta: float) -> void:
	super(delta)
	if cooldown > 0.0: cooldown -= delta
	if !focused || !get_parent().focused: return
	
	if Input.is_action_just_pressed(&"ui_select"):
		if tweak_description_text:
			$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)


func _handle_right_click() -> void:
	if focused && tweak_description_text:
		$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)


func _on_button_pressed() -> void:
	current_vec = Vector2(spin_box_x.value, spin_box_y.value)
	$Label2.text = format_vec2(current_vec)
	_play_sound()
	var _quick_node = Scenes.current_scene.get_node("Tweaks/SubViewportContainer/SubViewport/Tweaks/SkinTweaks/HSeparatorSpawn/QuickSettingsScript")
	var powerup_name = get_parent().get_meta(&"_powerup_name")
	var submenu_name = get_parent().get_meta(&"_submenu_name", "")
	if !powerup_name: return
	var saved: Array = [_component_value(spin_box_x), _component_value(spin_box_y)]
	if submenu_name:
		_quick_node.skin_tweaks[powerup_name][submenu_name][tweak_name] = saved
	else:
		_quick_node.skin_tweaks[powerup_name][tweak_name] = saved


func format_vec2(vec: Vector2) -> String:
	return "(%s, %s)" % [_format_component(vec.x), _format_component(vec.y)]


func _is_int_step() -> bool:
	return is_equal_approx(spin_box_x.step, 1.0)


func _format_component(n: float) -> String:
	if _is_int_step():
		return str(int(roundf(n)))
	var rounded := snappedf(n, 0.00001)
	if is_equal_approx(rounded, roundf(rounded)):
		return str(int(roundf(rounded)))
	return ("%.5f" % rounded).rstrip("0").rstrip(".")


func _component_value(spin_box: SpinBox) -> Variant:
	if _is_int_step():
		return int(roundf(spin_box.value))
	return snappedf(spin_box.value, 0.00001)
