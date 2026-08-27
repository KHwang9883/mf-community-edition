extends InputRichTextLabel

@export var text_keyboard: String = "to select a level, use corresponding number buttons."
@export var text_joypad: String = "to select a level, press {m_up} + {a_tab}."
@export var text_joypad_no_up: String = "to select a level, press {a_tab}."
@export var hold_up_to_select_level: bool = true

var _override_template: String = ""


func _ready() -> void:
	_apply_template()
	super._ready()


func update_text() -> void:
	_apply_template()
	super.update_text()


func set_override_template(template: String) -> void:
	_override_template = template
	if is_node_ready():
		update_text()


func set_hold_up_to_select_level(enabled: bool) -> void:
	hold_up_to_select_level = enabled
	if is_node_ready() && _override_template.is_empty():
		update_text()


func _apply_template() -> void:
	if !_override_template.is_empty():
		input_template = _override_template
	elif SettingsManager.device_keyboard:
		input_template = text_keyboard
	elif hold_up_to_select_level:
		input_template = text_joypad
	else:
		input_template = text_joypad_no_up
