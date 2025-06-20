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
