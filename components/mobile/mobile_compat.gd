extends Node

const DESKTOP_ONLY_SETTINGS_ITEMS: PackedStringArray = [
	"Controls", "Scale", "Fullscreen", "VSync", "Filter",
]
const SKIN_EDITOR_SCRIPT_PATH := "res://stages/main_menu/objects/character_editor/skin_open_editor.gd"
const SKIN_DIR_SCRIPT_PATH := "res://stages/main_menu/objects/character_editor/skin_open_dir.gd"
const LIVESPLIT_SCRIPT_PATH := "res://stages/main_menu/objects/tweaks_livesplit_sel.gd"
const BLINKING_SCRIPT_PATH := "res://engine/scenes/main_menu/scripts/selector_blinking.gd"
const PAUSE_SETTINGS_PATH := "/root/Pause/Settings/SubViewportContainer/SubViewport/Options"
const TOUCH_SETTINGS_ROW := preload("res://components/mobile/settings_touch_row.gd")

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
	_setup_gamepad_support()
	_patch_options_container(get_node_or_null(PAUSE_SETTINGS_PATH))
	Scenes.scene_changed.connect(_on_scene_changed)


func _notification(what: int) -> void:
	if !android:
		return
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_handle_go_back()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_normalize_joypad_bindings()


func is_touch_device() -> bool:
	return android


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
	var tweaks_page := to.get_node_or_null(
		NodePath("Tweaks/SubViewportContainer/SubViewport/Tweaks/Tweaks")
	)
	if tweaks_page:
		_inject_touch_rows(tweaks_page)
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
		var items: Array[CanvasItem] = []
		for child in container.get_children():
			if child is HSeparator || child is VSeparator:
				continue
			if child.is_queued_for_deletion():
				continue
			if !(child is Control):
				continue
			items.append(child)
		node.set(&"items", items)
		print("[MobileCompat] Resynced %d blink item(s) for %s" % [items.size(), container.name])


func _inject_touch_rows(page: Node) -> void:
	if page == null || !page.has_method("_update_selectors") || page.has_node("TouchSize"):
		return
	var anchor := page.get_node_or_null(NodePath("TweakLiveSplitSel"))
	if anchor == null:
		anchor = page.get_node_or_null(NodePath("Exit2"))
	for entry in [
		["TouchSize", "size"],
		["TouchOpacity", "opacity"],
		["TouchLayout", "layout"],
		["TouchStick", "stick"],
		["TouchReset", "reset"],
	]:
		var row := HBoxContainer.new()
		row.name = entry[0]
		row.set_script(TOUCH_SETTINGS_ROW)
		row.kind = entry[1]
		page.add_child(row)
		if anchor:
			page.move_child(row, anchor.get_index())
	page._update_selectors()
	_resync_blinkers(page)
	_hook_selection_restore(page)
	_resync_camera_limits(page)
	print("[MobileCompat] Injected touch settings rows into Tweaks/general page")


func _resync_camera_limits(page: Node) -> void:
	var parent := page.get_parent()
	if parent == null:
		return
	for node in parent.get_children():
		var script := node.get_script() as Script
		if !script || !script.resource_path.ends_with("camera_tweaks_menu.gd"):
			continue
		if node.get(&"menu_controller") != page || !node.has_method(&"update_limit"):
			continue
		_apply_camera_limit_update(node)


func _apply_camera_limit_update(camera: Node) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(camera) && camera.has_method(&"update_limit"):
		camera.update_limit()


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
