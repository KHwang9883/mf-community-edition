extends Node

const DESKTOP_ONLY_SETTINGS_ITEMS: PackedStringArray = [
	"Scale", "Fullscreen", "VSync", "Filter",
]
const SKIN_EDITOR_SCRIPT_PATH := "res://stages/main_menu/objects/character_editor/skin_open_editor.gd"
const SKIN_DIR_SCRIPT_PATH := "res://stages/main_menu/objects/character_editor/skin_open_dir.gd"
const LIVESPLIT_SCRIPT_PATH := "res://stages/main_menu/objects/tweaks_livesplit_sel.gd"
const BLINKING_SCRIPT_PATH := "res://engine/scenes/main_menu/scripts/selector_blinking.gd"
const PAUSE_SETTINGS_PATH := "/root/Pause/Settings/SubViewportContainer/SubViewport/Options"
const PAUSE_CONTROLS_PATH := "/root/Pause/Controls/SubViewportContainer/SubViewport/Options"
const CONTROLS_PATH := "Controls/SubViewportContainer/SubViewport/Options"
const TOUCH_SETTINGS_ROW := preload("res://components/mobile/settings_touch_row.gd")
const TOUCH_INPUT_DISPLAY := preload("res://components/mobile/touch_input_display.gd")
const SUBMENU_SELECTION_SCRIPT := preload("res://engine/scenes/main_menu/scripts/controls_submenu_selection.gd")
const MENU_CONTROLLER_SCRIPT := preload("res://engine/components/ui/generic/menu_items_controller.gd")
const MENU_TEXT_FONT := preload("res://engine/fonts/font_variations/smb_variation.tres")
const TEXT_GRADIENT := preload("res://components/mobile/text_gradient.gdshader")

const MENU_TEXT_COLOR := Color(1, 1, 1, 1)
const MENU_TEXT_OUTLINE := Color(0.156863, 0.156863, 0.156863, 0.784314)
const MENU_FONT_SIZE := 28

## Bevel gradient sampled from the blue labels in controls_main.png.
const MENU_BLUE_TOP := Color(0.918, 0.918, 1)
const MENU_BLUE_BOTTOM := Color(0.349, 0.349, 0.573)

const TOUCH_ROWS := [
	["TouchSize", "size"],
	["TouchOpacity", "opacity"],
	["TouchLayout", "layout"],
	["TouchStick", "stick"],
	["TouchReset", "reset"],
]

var android := false


func _ready() -> void:
	android = (
		OS.get_name() == "Android"
		or OS.has_feature("android")
		or OS.get_environment("MFCE_FORCE_MOBILE") == "1"
	)
	if !android:
		return
	_setup_mobile_skins_dir()
	_neuter_desktop_window_settings()
	_install_touch_input_display()
	_setup_gamepad_support()
	_patch_options_container(get_node_or_null(PAUSE_SETTINGS_PATH))
	# Deferred so the touch row script can reach the TouchControls autoload,
	# which is registered after this one.
	_inject_touch_menu.call_deferred(get_node_or_null(PAUSE_CONTROLS_PATH))
	Scenes.scene_changed.connect(_on_scene_changed)
	_ensure_immersive_mode.call_deferred()
	_watch_console.call_deferred()


func _notification(what: int) -> void:
	if !android:
		return
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_handle_go_back()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_normalize_joypad_bindings()
		_ensure_immersive_mode()
	elif what == NOTIFICATION_APPLICATION_RESUMED \
			|| what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_ensure_immersive_mode()


func is_touch_device() -> bool:
	return android


## 是否运行在真正的 Android 上（MFCE_FORCE_MOBILE 只在桌面上模拟，不可改窗口模式）。
func _is_android_platform() -> bool:
	return OS.get_name() == "Android" || OS.has_feature("android")


## 部分设备在窗口失去焦点后会重新显示状态栏和导航栏（侧边栏），并一直挡住画面。
## 该分支的 Android 实现里 window_set_mode(FULLSCREEN) 会直接调用
## enable_immersive_mode(true)，且不会因为模式未变而提前返回，所以每次重新获得
## 焦点时再设置一次即可重新隐藏系统栏。
func _ensure_immersive_mode() -> void:
	if !_is_android_platform():
		return
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func inject_action(action: StringName, pressed: bool, strength: float = 1.0) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = pressed
	ev.strength = strength if pressed else 0.0
	Input.parse_input_event(ev)


func remove_user_file(path: String) -> Error:
	return DirAccess.remove_absolute(path)


const POPUP_BASE_SHORT := 480.0


func popup_scale() -> float:
	if !android:
		return 1.0
	var win := Vector2(DisplayServer.window_get_size())
	return clampf(minf(win.x, win.y) / POPUP_BASE_SHORT, 1.0, 4.0)


func popup_theme() -> Theme:
	var theme := Theme.new()
	theme.default_font_size = int(16 * popup_scale())
	return theme


func scale_popup_window(win: Window) -> void:
	if !android || !is_instance_valid(win) || win.has_meta(&"popup_scaled"):
		return
	win.set_meta(&"popup_scaled", true)
	var s := popup_scale()
	win.theme = popup_theme()
	if win.size.x < 200.0 * s || win.size.y < 150.0 * s:
		win.size = Vector2i((Vector2(win.size) * s).floor())


func collect_windows(root: Node) -> Array[Window]:
	var out: Array[Window] = []
	var stack: Array[Node] = [root]
	while !stack.is_empty():
		var node: Node = stack.pop_back()
		for child in node.get_children():
			stack.append(child)
		if node is Window && node != get_tree().root:
			out.append(node)
	return out


func _scan_and_scale_popups(root: Node) -> void:
	var stack: Array[Node] = [root]
	while !stack.is_empty():
		var node: Node = stack.pop_back()
		for child in node.get_children():
			stack.append(child)
		if node is Window:
			scale_popup_window(node)


func _setup_mobile_skins_dir() -> void:
	SkinsManager.base_dir = "user://skins"
	DirAccess.make_dir_recursive_absolute(SkinsManager.base_dir)
	SkinsManager.load_external_textures()


func _neuter_desktop_window_settings() -> void:
	if SettingsManager.settings.get("scale", 0) != 0:
		SettingsManager.settings.scale = 0
	SettingsManager.settings.fullscreen = false


func _handle_go_back() -> void:
	if _close_topmost_popup():
		return
	# 正在等待绑定按键时，虚拟按键按设计不响应，返回键是唯一可用的退出方式，
	# 因此要优先于其它返回行为，等同于桌面上的 ESC（取消本次绑定）。
	if _cancel_pending_keybind():
		return
	if TouchControls.import_block_active():
		return
	if TouchControls.edit_mode:
		TouchControls.set_layout_edit(false)
		return
	var cs := Scenes.current_scene
	if cs != null && cs.get(&"_skin_test_level"):
		inject_action(&"ui_cancel", true)
		inject_action(&"ui_cancel", false)
		return
	if cs != null && (cs is Stage2D || cs is Map2D):
		TouchControls.press_pause(true)
	else:
		inject_action(&"ui_cancel", true)
		inject_action(&"ui_cancel", false)


## 触屏已经没有常驻的键盘按钮了，控制台弹出后把焦点交给它自己的输入框，
## 否则 Android 上不会弹出输入法。顺带补一个补全按钮（见下）。
func _watch_console() -> void:
	var console := get_node_or_null(^"/root/Console")
	if console == null || console.has_meta(&"console_watched"):
		return
	console.set_meta(&"console_watched", true)
	console.visibility_changed.connect(_on_console_visibility_changed)
	_inject_console_complete_button(console)


## 软键盘上没有 Tab，而命令补全只认 Tab（console.gd 里 ui_focus_next →
## move_suggestion()）。屏幕上的 TAB 按键也不行：控制台是盖在虚拟按键层之上的
## 窗口，而且它在虚拟按键显隐规则里属于弹窗（打开时按键会隐藏）。所以直接在
## 它的输入行里加一个"补全"按钮，调用控制台自己的 move_suggestion()。
func _inject_console_complete_button(console: Node) -> void:
	var ui := console.get_node_or_null(^"UI")
	if ui == null:
		return
	var button := Button.new()
	button.name = "Complete"
	button.text = "TAB"
	# 不要抢走输入框的焦点，否则输入法会收起来。
	button.focus_mode = Control.FOCUS_NONE
	button.anchor_left = 1.0
	button.anchor_top = 1.0
	button.anchor_right = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = -130.0
	button.offset_top = -35.0
	button.offset_right = -70.0
	button.offset_bottom = -4.0
	button.pressed.connect(func(): console.call(&"move_suggestion", 1))
	ui.add_child(button)
	print("[MobileCompat] Added console Tab/complete button")


func _on_console_visibility_changed() -> void:
	var console := get_node_or_null(^"/root/Console")
	if console == null || !(console as Window).visible:
		return
	var input := console.get_node_or_null(^"UI/CmdInput")
	if input is LineEdit:
		(input as LineEdit).grab_focus.call_deferred()


## 按键设置里选中某一行后会进入等待按键状态（显示 "..."），此时该页菜单会被
## 取消焦点，虚拟按键也不参与绑定，触屏玩家没有外接设备就退不出来。
## 这里找到正在等待的那一行，走它自己的收尾流程（changing = false 并恢复菜单焦点），
## 效果与桌面按 ESC 相同，但不会把任何按键写进配置。
func _cancel_pending_keybind() -> bool:
	var stack: Array[Node] = [get_tree().root]
	while !stack.is_empty():
		var node: Node = stack.pop_back()
		if node.get(&"changing") == true && node.has_method(&"_after_change"):
			node.set(&"changing", false)
			node.get_parent().set(&"focused", true)
			print("[MobileCompat] Cancelled pending key rebind on '%s'" % node.name)
			return true
		for child in node.get_children():
			stack.append(child)
	return false


func _close_topmost_popup() -> bool:
	var candidates: Array[Window] = []
	var stack: Array[Node] = [get_tree().root, Scenes.current_scene]
	while !stack.is_empty():
		var node: Node = stack.pop_back()
		if node == null:
			continue
		for child in node.get_children():
			stack.append(child)
		if node is Window && node != get_tree().root && node.visible:
			candidates.append(node)
	if candidates.is_empty():
		return false
	var target: Window = candidates[0]
	for candidate in candidates:
		if candidate is ConfirmationDialog:
			target = candidate
			break
	if target.has_signal(&"canceled"):
		target.canceled.emit()
	target.hide()
	return true


const STICK_UI_BINDINGS := {
	&"ui_left": [0, -1.0],
	&"ui_right": [0, 1.0],
	&"ui_up": [1, -1.0],
	&"ui_down": [1, 1.0],
}


## 用主仓库的触屏提示渲染替换 Thunder.input：虚拟按键下显示屏幕按键 / 键盘按键，
## 接手柄时显示手柄图标，避免出现 "Joy N"。
func _install_touch_input_display() -> void:
	Thunder.input = TOUCH_INPUT_DISPLAY.new()
	print("[MobileCompat] Installed touch input display")


## 触屏上没有物理键盘，提示里的 " key" 后缀（JUMP key、Space key）没有意义，
## 而且会让屏幕按键提示变成 "JUMP key"。这里统一去掉。
func _disable_keyboard_button_suffix(root: Node) -> void:
	var stack: Array[Node] = [root]
	while !stack.is_empty():
		var node: Node = stack.pop_back()
		if node is InputRichTextLabel && node.keyboard_as_button:
			node.keyboard_as_button = false
			if node.is_node_ready():
				node.update_text()
		for child in node.get_children():
			stack.append(child)


func _setup_gamepad_support() -> void:
	ProjectSettings.set_setting(
		&"input_devices/joypads/ignore_joypad_on_unfocused_application",
		false
	)
	SettingsManager.settings_saved.connect(_normalize_joypad_bindings)
	SettingsManager.settings_loaded.connect(_normalize_joypad_bindings_deferred)
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_add_stick_ui_bindings()
	var patched := _normalize_joypad_bindings()
	print("[MobileCompat] Joypad 0 at startup: '%s'" % Input.get_joy_name(0))
	print("[MobileCompat] Normalized device bindings on %d input action(s)" % patched)


func _on_joy_connection_changed(device: int, connected: bool) -> void:
	print(
		"[MobileCompat] Joypad %d %s: '%s'"
		% [device, "connected" if connected else "disconnected", Input.get_joy_name(device)]
	)
	if connected:
		_normalize_joypad_bindings()


func _normalize_joypad_bindings_deferred() -> void:
	_normalize_joypad_bindings.call_deferred()


func _normalize_joypad_bindings() -> int:
	var patched := 0
	for action in InputMap.get_actions():
		for ev in InputMap.action_get_events(action):
			if (ev is InputEventJoypadButton || ev is InputEventJoypadMotion) \
					&& ev.device != -1:
				ev.device = -1
				patched += 1
	return patched


func _add_stick_ui_bindings() -> void:
	for action in STICK_UI_BINDINGS:
		var axis: int = STICK_UI_BINDINGS[action][0]
		var value: float = STICK_UI_BINDINGS[action][1]
		var found := false
		for ev in InputMap.action_get_events(action):
			if ev is InputEventJoypadMotion && ev.axis == axis \
					&& signf(ev.axis_value) == signf(value):
				found = true
				break
		if !found:
			var motion := InputEventJoypadMotion.new()
			motion.device = -1
			motion.axis = axis
			motion.axis_value = value
			InputMap.action_add_event(action, motion)


func _on_scene_changed(to: Node) -> void:
	var options := to.get_node_or_null(NodePath("Settings/SubViewportContainer/SubViewport/Options"))
	if options:
		_patch_options_container(options)
	_inject_touch_menu(to.get_node_or_null(NodePath(CONTROLS_PATH)))
	_patch_shop_hint_for_touch(to)
	_disable_keyboard_button_suffix(to)
	_remove_nodes_with_script(to, SKIN_EDITOR_SCRIPT_PATH)
	_remove_nodes_with_script(to, SKIN_DIR_SCRIPT_PATH, {"is_docs": false})
	_remove_nodes_with_script(to, LIVESPLIT_SCRIPT_PATH)
	_scan_and_scale_popups(to)


func _patch_options_container(options: Node) -> void:
	if options == null:
		return
	var removed := false
	for item_name in DESKTOP_ONLY_SETTINGS_ITEMS:
		var item: Node = options.get_node_or_null(NodePath(item_name))
		if item:
			options.remove_child(item)
			item.queue_free()
			removed = true
	if removed && options.has_method("_update_selectors"):
		options._update_selectors()
		if options.has_method("move_selector"):
			options.move_selector(0, true)
	if removed:
		print("[MobileCompat] Stripped %d desktop-only item(s) from %s" % [DESKTOP_ONLY_SETTINGS_ITEMS.size(), options.get_parent().get_parent().get_parent()])
	_resync_blinkers(options)
	_hook_selection_restore(options)


var _restore_prev := {}


func _hook_selection_restore(container: Node) -> void:
	if !container.has_signal(&"selected") || container.has_meta(&"restore_hooked"):
		return
	container.set_meta(&"restore_hooked", true)
	container.selected.connect(
		_on_container_selected.bind(container)
	)


func _on_container_selected(
	_idx: int, node: Control, _immediate: bool, _mouse: bool, container: Node
) -> void:
	var prev = _restore_prev.get(container)
	if prev != null && prev != node && is_instance_valid(prev):
		prev.modulate.a = 1.0
	_restore_prev[container] = node


func _resync_blinkers(container: Node) -> void:
	var parent := container.get_parent()
	if parent == null:
		return
	for node in parent.get_children():
		var script := node.get_script() as Script
		if !script || script.resource_path != BLINKING_SCRIPT_PATH:
			continue
		if node.get(&"menu_items_controller") != container:
			continue
		var first_child: bool = node.get(&"modulate_first_child")
		var items: Array[CanvasItem] = []
		for child in container.get_children():
			if child is HSeparator || child is VSeparator:
				continue
			if child.is_queued_for_deletion():
				continue
			if !(child is Control):
				continue
			if first_child:
				if child.get_child_count() > 0 && child.get_child(0) is CanvasItem:
					items.append(child.get_child(0))
				continue
			items.append(child)
		node.set(&"items", items)
		print("[MobileCompat] Resynced %d blink item(s) for %s" % [items.size(), container.name])


func _inject_touch_menu(page: Node) -> void:
	if page == null || !page.has_method("_update_selectors") || page.has_node(NodePath("Touch")):
		return
	var viewport := page.get_parent()
	var back := page.get_node_or_null(NodePath("Back"))
	var main_selector: Node = viewport.get_node_or_null(NodePath("Selector")) if viewport else null
	# A submenu "Back" row (script that returns to the main Options list) is the
	# one used by GameplayOptions/MenuOptions, not the top-level Back.
	var back_template: Node = viewport.get_node_or_null(NodePath("GameplayOptions/Back"))
	if back == null || main_selector == null || back_template == null:
		return

	var touch_page := _build_touch_page(page, back_template)
	viewport.add_child(touch_page)

	var touch_selector: Node = main_selector.duplicate()
	touch_selector.name = "TouchSelector"
	touch_selector.visible = false
	viewport.add_child(touch_selector)

	var touch_blinking := Node.new()
	touch_blinking.name = "TouchBlinking"
	touch_blinking.set_script(load(BLINKING_SCRIPT_PATH))
	touch_blinking.set(&"menu_items_controller_path", NodePath("../TouchOptions"))
	touch_blinking.set(&"modulate_first_child", true)
	viewport.add_child(touch_blinking)

	touch_page.selected.connect(touch_selector.handle_selection)
	touch_page.selected.connect(touch_blinking.handle_selection)
	var camera := viewport.get_node_or_null(NodePath("Camera2D"))
	if camera:
		touch_page.selected.connect(camera.handle_selection)

	var entry := _build_touch_entry()
	page.add_child(entry)
	page.move_child(entry, back.get_index())

	page._update_selectors()
	_resync_blinkers(page)
	_resync_blinkers(touch_page)
	_hook_selection_restore(page)
	print("[MobileCompat] Injected touch settings submenu into %s" % viewport.get_parent().name)


func _build_touch_page(page: Node, back_template: Node) -> Node:
	var touch_page := VBoxContainer.new()
	touch_page.name = "TouchOptions"
	touch_page.visible = false
	touch_page.anchor_left = 1.0
	touch_page.anchor_right = 1.0
	touch_page.offset_left = -456.0
	touch_page.offset_top = 16.0
	touch_page.offset_right = -64.0
	touch_page.offset_bottom = 464.0
	touch_page.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	touch_page.set_script(MENU_CONTROLLER_SCRIPT)
	touch_page.set(&"focused", false)
	touch_page.set(&"prev_screen_node_path", NodePath("Back"))
	touch_page.set(&"control_sound", page.get(&"control_sound"))

	for entry in TOUCH_ROWS:
		var row := HBoxContainer.new()
		row.name = entry[0]
		row.custom_minimum_size = Vector2(0, 36)
		row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.set_script(TOUCH_SETTINGS_ROW)
		row.set(&"kind", entry[1])
		touch_page.add_child(row)

	var separator := HSeparator.new()
	separator.name = "HSeparator"
	separator.add_theme_constant_override(&"separation", 6)
	separator.add_theme_stylebox_override(&"separator", StyleBoxEmpty.new())
	touch_page.add_child(separator)

	var submenu_back: Node = back_template.duplicate()
	submenu_back.name = "Back"
	submenu_back.set(&"focused", false)
	touch_page.add_child(submenu_back)
	return touch_page


func _build_touch_entry() -> Control:
	var entry := HBoxContainer.new()
	entry.name = "Touch"
	entry.custom_minimum_size = Vector2(0, 36)
	entry.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	entry.set_script(SUBMENU_SELECTION_SCRIPT)
	entry.set(&"move_to_path", NodePath("../../TouchOptions"))
	entry.set(&"menu_selector_path", NodePath("../../TouchSelector"))
	var label := Label.new()
	label.name = "Text"
	label.text = "TOUCH"
	label.uppercase = true
	label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.add_theme_font_override(&"font", MENU_TEXT_FONT)
	label.add_theme_font_size_override(&"font_size", MENU_FONT_SIZE)
	label.add_theme_color_override(&"font_color", MENU_TEXT_COLOR)
	label.add_theme_color_override(&"font_outline_color", MENU_TEXT_OUTLINE)
	label.add_theme_constant_override(&"outline_size", 6)
	var material := ShaderMaterial.new()
	material.shader = TEXT_GRADIENT
	material.set_shader_parameter(&"gradient_top", MENU_BLUE_TOP)
	material.set_shader_parameter(&"gradient_bottom", MENU_BLUE_BOTTOM)
	label.material = material
	entry.add_child(label)

	# The "PRESS ENTER" prompt of the sibling entries. The entry script fades it
	# with the row blink, so touch players get the same hint as everyone else.
	var value := TOUCH_SETTINGS_ROW.make_press_enter_hint()
	value.name = "Value"
	entry.add_child(value)
	return entry


## Expert mode explains the item shop as "hold up + Tab". Touch players open it
## with the on-screen EXTRA button instead, so those hints are reworded. Only
## plain-text item shop messages are rewritten here: {a_tab} tokens (including the
## save room's world/level select hints) already render as EXTRA through
## touch_input_display.gd.
func _patch_shop_hint_for_touch(root: Node) -> void:
	var stack: Array[Node] = [root]
	while !stack.is_empty():
		var node: Node = stack.pop_back()
		for child in node.get_children():
			stack.append(child)
		_rewrite_shop_hint(node)


func _rewrite_shop_hint(node: Node) -> void:
	var hint := node as InputRichTextLabel
	if hint != null:
		if !hint.input_template.to_lower().contains("item shop") \
				|| !hint.input_template.contains("{a_tab}"):
			return
		hint.input_template = hint.input_template.replace("{a_tab}", "EXTRA")
		hint.update_text()
		print("[MobileCompat] Rephrased item shop sign for touch input")
		return
	var message: Variant = node.get(&"message")
	if !(message is String) || !str(message).to_lower().contains("item shop"):
		return
	var rewritten := (message as String).replace("UP + TAB", "UP + EXTRA")
	if rewritten == message:
		return
	node.set(&"message", rewritten)
	print("[MobileCompat] Rephrased item shop hint for touch input")


func _remove_nodes_with_script(root: Node, script_path: String, prop_filter: Dictionary = {}) -> void:
	var stack: Array[Node] = [root]
	while !stack.is_empty():
		var node: Node = stack.pop_back()
		for child in node.get_children():
			stack.append(child)
		var script := node.get_script() as Script
		if !script || script.resource_path != script_path:
			continue
		var matches := true
		for key in prop_filter:
			if node.get(key) != prop_filter[key]:
				matches = false
				break
		if !matches:
			continue
		var parent := node.get_parent()
		parent.remove_child(node)
		node.queue_free()
		print("[MobileCompat] Removed %s entry (%s)" % [script_path.get_file(), node.name])
		if parent.has_method("_update_selectors"):
			parent._update_selectors()
			if parent.has_method("move_selector"):
				parent.move_selector(0, true)
		_resync_blinkers(parent)
