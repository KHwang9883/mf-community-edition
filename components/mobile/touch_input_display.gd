extends "res://engine/singletones/scripts/Thunder.gd".InputDisplay
## 触屏设备的按键提示渲染（在主仓库里替换 [code]Thunder.input[/code]，不改动引擎子模块）。
##
## 虚拟按键开启时：带有屏幕按键的动作（方向键 / JUMP / FIRE / EXTRA / 暂停）
## 直接显示对应的屏幕按键；其余动作退回键盘按键名，不再出现 "Joy N"。
## 连接了物理手柄时改用真实的手柄按键图标，同样不出现 "Joy N"。

## 动作 → 屏幕上对应按键的提示文本。方向上使用文字，避免像素字体缺少箭头字形。
const TOUCH_BUTTON_HINTS := {
	&"m_left": "LEFT",
	&"m_right": "RIGHT",
	&"m_up": "UP",
	&"m_down": "DOWN",
	&"ui_left": "LEFT",
	&"ui_right": "RIGHT",
	&"ui_up": "UP",
	&"ui_down": "DOWN",
	&"m_jump": "JUMP",
	&"ui_accept": "JUMP",
	&"m_run": "FIRE",
	&"m_attack": "FIRE",
	&"ui_cancel": "FIRE",
	&"m_extra": "EXTRA",
	&"ui_select": "EXTRA",
	&"a_tab": "EXTRA",
	&"pause_toggle": "PAUSE",
}

## Xbox 图标集的合法下标（与引擎 [method _has_gamepad_icon] 中的判定一致）。
const XBOX_ICON_MAX := 15
const XBOX_ICON_EXCEPTIONS: Array[int] = [-1, 48, 50]


func get_input_rich_text(
		action: StringName, separator: String = " / ", icon_height: String = "1em"
) -> String:
	if _use_touch_hints():
		return _touch_hint(action)
	if _touch_device() && _joypad_connected():
		return _joypad_rich_text(action, separator, icon_height)
	return super(action, separator, icon_height)


func get_input_plain_text(action: StringName, separator: String = " / ") -> String:
	if _use_touch_hints():
		return _touch_hint(action)
	if _touch_device() && _joypad_connected():
		# 普通 Label 放不下图标，退化为键盘按键名而不是 "Joy N"。
		return _get_keyboard_input_text(action)
	return super(action, separator)


## 手柄提示风格为 raw（未识别出手柄型号）时，用 Xbox 图标集兜底，
## 保证连接了物理手柄也能显示按键图案。
func get_gamepad_icon_texture() -> Texture2D:
	var tex := super()
	if tex == null && _touch_device():
		return GAMEPAD_ICONS_XBOX
	return tex


func _has_gamepad_icon(joy_index: int) -> bool:
	if _touch_device() && SettingsManager.get_gamepad_hint() == "raw":
		return _xbox_has_icon(joy_index)
	return super(joy_index)


func _xbox_has_icon(joy_index: int) -> bool:
	return !(
		(joy_index > XBOX_ICON_MAX && joy_index < 40)
		|| joy_index > 51
		|| joy_index in XBOX_ICON_EXCEPTIONS
	)


# --- 触屏判定 ---

func _touch_device() -> bool:
	return MobileCompat.is_touch_device()


## 只要屏幕上正显示虚拟按键，就按屏幕按键显示提示（JUMP/FIRE/EXTRA…），
## 与是否接着物理手柄无关：玩家此刻看的是屏幕按键。
func _use_touch_hints() -> bool:
	if !_touch_device():
		return false
	if !SettingsManager.get_custom_setting("touch_enabled", true):
		return false
	return _virtual_buttons_active()


func _virtual_buttons_active() -> bool:
	var loop := Engine.get_main_loop() as SceneTree
	if loop == null || loop.root == null:
		return true
	var touch_controls := loop.root.get_node_or_null(^"TouchControls")
	if touch_controls == null || !touch_controls.has_method(&"is_virtual_buttons_active"):
		# 提示标签比 TouchControls 更早渲染时，触屏默认按屏幕按键显示。
		return true
	return touch_controls.is_virtual_buttons_active()


func _joypad_connected() -> bool:
	return !Input.get_connected_joypads().is_empty()


# --- 提示文本 ---

func _touch_hint(action: StringName) -> String:
	var label: String = TOUCH_BUTTON_HINTS.get(action, "")
	if !label.is_empty():
		return label
	return _get_keyboard_input_text(action)


## 手柄连接时按真实按键图案渲染，最多显示两个绑定。
func _joypad_rich_text(action: StringName, separator: String, icon_height: String) -> String:
	var indices: Array = SettingsManager.settings.controls_joypad.get(str(action), [])
	if indices.is_empty():
		return "<NOT SET>"
	var parts := PackedStringArray()
	var shown := 0
	for joy_index in indices:
		if shown >= 2:
			break
		parts.append(get_joy_icon_bbcode(int(joy_index), icon_height))
		shown += 1
	return separator.join(parts)