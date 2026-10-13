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
	elif _use_number_keys():
		input_template = text_keyboard
	elif hold_up_to_select_level:
		input_template = text_joypad
	else:
		input_template = text_joypad_no_up


## 触屏上选关/选世界改用 EXTRA（= Tab），与手柄一致，所以提示走手柄文案。
## 只有"键盘 + 非触屏"才提示数字键（数字键输入本身仍然保留）。
func _use_number_keys() -> bool:
	if MobileCompat.is_touch_device():
		return false
	return SettingsManager.device_keyboard
