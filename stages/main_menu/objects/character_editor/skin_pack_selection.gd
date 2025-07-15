extends MenuSelection

@onready var valu = get_node_or_null(^"Value")
var _timer: float
@export var skin_id: String
@onready var skin_pack_select: HBoxContainer = $"../../Tweaks/SkinPackSelect"

func _physics_process(delta: float) -> void:
	super(delta)
	if !valu:
		return
	if focused && SkinsManager.current_skin != skin_id:
		_timer += delta * 10
		valu.modulate.a = min((cos(_timer) / 2.5) + 0.6, 1.0)
	else:
		valu.modulate.a = 0.0


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
