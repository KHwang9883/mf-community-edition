extends MenuSelection

const SKIN_DELETE_PROMPT := preload("res://components/mobile/skin_delete_prompt.gd")
const DELETE_HINT_SCRIPT := preload("res://stages/main_menu/objects/label_space_key.gd")
const DELETE_HINT_META := &"skin_delete_hint"
const DELETE_HINT_OWNER := &"skin_delete_hint_owner"
const DELETE_HINT_PATH := "Tweaks"
const DELETE_HINT_TEXT := "press {ui_select}\nto delete\nthis skin"

@onready var valu = get_node_or_null(^"Value")
var _timer: float
var _hint_owned := false
@export var skin_id: String
@onready var skin_pack_select: HBoxContainer = $"../../Tweaks/SkinPackSelect"

func _physics_process(delta: float) -> void:
	super(delta)
	_update_delete_hint()
	if MobileCompat.is_touch_device() && focused && get_parent().focused \
			&& !skin_id.is_empty() && skin_id != "none" \
			&& Input.is_action_just_pressed(&"ui_select"):
		_open_delete_prompt()
		return
	if !valu:
		return
	if focused && SkinsManager.current_skin != skin_id:
		_timer += delta * 10
		valu.modulate.a = min((cos(_timer) / 2.5) + 0.6, 1.0)
	else:
		valu.modulate.a = 0.0


func _handle_focused(focus: bool) -> void:
	super(focus)
	if focus && MobileCompat.is_touch_device():
		_show_delete_hint()


func _exit_tree() -> void:
	_hide_delete_hint()


## The hint lives on the tweaks menu root (same place and style as the
## description prompt in the bottom-left corner); only the focused skin row
## shows it and only while the skin submenu is the active page.
func _update_delete_hint() -> void:
	if !_hint_owned:
		return
	var hint := _find_delete_hint()
	if hint == null || hint.get_meta(DELETE_HINT_OWNER, 0) != get_instance_id():
		_hint_owned = false
		return
	if !focused || !get_parent().focused || !is_visible_in_tree():
		hint.set_meta(DELETE_HINT_OWNER, 0)
		hint.visible = false
		_hint_owned = false


func _show_delete_hint() -> void:
	if skin_id.is_empty() || skin_id == "none":
		return
	var hint := _ensure_delete_hint()
	if hint == null:
		return
	hint.set_meta(DELETE_HINT_OWNER, get_instance_id())
	hint.visible = true
	_hint_owned = true


func _hide_delete_hint() -> void:
	if !_hint_owned:
		return
	_hint_owned = false
	var hint := _find_delete_hint()
	if hint == null || hint.get_meta(DELETE_HINT_OWNER, 0) != get_instance_id():
		return
	hint.set_meta(DELETE_HINT_OWNER, 0)
	hint.visible = false


func _find_delete_hint() -> Control:
	var cs := Scenes.current_scene
	if cs == null || !is_instance_valid(cs):
		return null
	var root := cs.get_node_or_null(NodePath(DELETE_HINT_PATH))
	if root == null:
		return null
	var hint: Control = root.get_meta(DELETE_HINT_META, null)
	if hint != null && is_instance_valid(hint):
		return hint
	return null


func _ensure_delete_hint() -> Control:
	var hint := _find_delete_hint()
	if hint != null:
		return hint
	var cs := Scenes.current_scene
	if cs == null || !is_instance_valid(cs):
		return null
	var root := cs.get_node_or_null(NodePath(DELETE_HINT_PATH))
	if root == null:
		return null

	# Clone the description hint instead of rebuilding its style, so the font
	# metrics (and therefore the line spacing) match exactly. Its script also
	# provides the same blinking fade animation.
	var template := root.get_node_or_null(NodePath("Label2"))
	if template == null:
		return null
	var label := template.duplicate() as RichTextLabel
	if label == null:
		return null
	if label.get_script() == null:
		label.set_script(DELETE_HINT_SCRIPT)
	label.name = "SkinDeleteHint"
	label.visible = false
	label.set(&"text_keyboard", DELETE_HINT_TEXT)
	label.set(&"text_joypad", DELETE_HINT_TEXT)
	root.add_child(label)
	root.set_meta(DELETE_HINT_META, label)
	return label


func _open_delete_prompt() -> void:
	var prompt: Node = SKIN_DELETE_PROMPT.new()
	prompt.set(&"skin_id", skin_id)
	prompt.set(&"row_index", get_parent().get(&"selectors").find(self))
	prompt.set(&"list_row", skin_pack_select)
	get_tree().root.add_child(prompt)


func _handle_select(mouse_input: bool = false) -> void:
	if SkinsManager.current_skin == skin_id:
		return
	super(mouse_input)
	SkinsManager.current_skin = skin_id
	SettingsManager.settings.skin = skin_id
	skin_pack_select.set_skin_pack_none_color()
	
	for i in get_tree().get_nodes_in_group(&"_skin_selection"):
		i.get_node("Label").remove_theme_color_override(&"font_color")
	if !skin_id.is_empty():
		$Label.add_theme_color_override(&"font_color", skin_pack_select.COLOR_SELECTED_SKIN)
	
	var _selector: MenuSelector = get_node_or_null("../../Selector11")
	if !_selector: return
	_selector.get_child(0)._set_frames()


var _template: String
func _update_text() -> void:
	var _events: Array[InputEvent] = InputMap.action_get_events(&"ui_accept")
	var _event: String = "enter"
	var _temp: String
	for i in _events:
		if i is InputEventKey:
			_temp = i.as_text().get_slice(' (', 0)
			#if SettingsManager.device_keyboard:
			_event = _temp
			break
		#elif i is InputEventJoypadButton:
		#	_temp = "Joy " + str(i.button_index)
		if _temp: _event = _temp
	
	valu.text = _template % [_event]

func _ready() -> void:
	if valu:
		valu.modulate.a = 0.0
		_template = valu.text
		_update_text()
		SettingsManager.settings_saved.connect(_update_text)
