extends CanvasLayer

const GAME_MOVE_ACTIONS: Array[StringName] = [&"m_left", &"m_right", &"m_up", &"m_down"]
const UI_MOVE_ACTIONS: Array[StringName] = [&"ui_left", &"ui_right", &"ui_up", &"ui_down"]
const DUMMY_ACTIONS: Array[StringName] = [&"vjoy_left", &"vjoy_right", &"vjoy_up", &"vjoy_down"]

const STICK_DIGITAL_THRESHOLD := 0.25

const OFFSET_KEYS: Array[String] = [
	"touch_off_dpad", "touch_off_jump", "touch_off_fire", "touch_off_extra", "touch_off_pause",
]
const STICK_SETTING := &"touch_stick"
const DUAL_SETTING := &"touch_dual_mode"

const ActionButton := preload("res://components/mobile/action_button.gd")

const FORCE_ACTION_PATHS: Array[String] = [
	"res://stages/cutscenes/",
	"res://stages/extra/world_u/ending_secret.tscn",
	"res://stages/extra/world_u/ending_bad.tscn",
]
const PAUSE_ONLY_PATHS: Array[String] = [
	"res://stages/extra/click_bonus_game/",
]
const FORCE_UI_PATHS: Array[String] = [
	"res://stages/mario_forever_flash/flash_title.tscn",
	"res://stages/extra/squario/squario_title.tscn",
	"res://stages/extra/expert_mode/advance_edition_title.tscn",
	"res://stages/extra/lost_map/lost_map_title.tscn",
]
const INTRO_PATH_PREFIX := "res://stages/intro/"
const TWEAK_PRESETS_PATH := "res://stages/intro/tweak_presets.tscn"
const HYBRID_MENU_PATHS: Array[String] = [
	"res://stages/extra/minix/minix.tscn",
	"res://stages/extra/climbing_minigame/climbing.tscn",
]

enum ViewState { MENU, STAGE, MAP, PAUSE_ONLY, HIDDEN }

signal layout_edit_changed(editing: bool)

var edit_mode := false

var _state: int = ViewState.MENU
var _insets := Rect2()
var _last_device_was_touch := true
var _last_tree_paused := false
var _last_pause_blocked := false
var _hybrid_scene := false
var _cached_menu_controllers: Array = []
var _last_embedded_menu := false
var _last_chooser_active := false
var _cached_windows: Array = []
var _last_popup_active := false
var _import_block := false
var _import_prev_paused := false
var _offsets := {}
var _default_positions := {}
var _drag_base := {}

var dpad_buttons: Array = []
var jump_btn
var fire_btn
var extra_btn
var pause_btn
var stick: VirtualJoystick
var _dpad_anchor := Vector2.ZERO
var _stick_prev_ui := [false, false, false, false]
var _stick_edit_finger := -1
var _stick_edit_mouse := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_offsets()
	_build_controls()
	Scenes.scene_changed.connect(_on_scene_signal)
	Scenes.scene_reloaded.connect(_on_scene_signal)
	Scenes.scene_ready.connect(_on_scene_signal)
	var pause_ctrl := Pause.get_node_or_null(NodePath("Pause"))
	if pause_ctrl:
		if pause_ctrl.has_signal(&"paused"):
			pause_ctrl.connect(&"paused", _on_pause_signal)
		if pause_ctrl.has_signal(&"unpaused"):
			pause_ctrl.connect(&"unpaused", _on_pause_signal)
	get_window().size_changed.connect(_relayout)
	_on_scene_signal.call_deferred()


func _input(event: InputEvent) -> void:
	if edit_mode:
		_handle_stick_edit_input(event)

	var was_touch := false
	if event is InputEventScreenTouch || event is InputEventScreenDrag:
		was_touch = true
	elif event is InputEventJoypadButton \
			|| event is InputEventJoypadMotion \
			|| event is InputEventKey:
		was_touch = false
	else:
		return
	if edit_mode && !was_touch:
		set_layout_edit(false)
	if was_touch != _last_device_was_touch:
		_last_device_was_touch = was_touch
		_sync_buttons.call_deferred()


## Repositions the virtual stick while the touch layout editor is open.
## The stick swallows presses as joystick input, so its drag is handled here,
## in _input, before the GUI layer sees the event. The stick shares the
## d-pad anchor & offset ("touch_off_dpad"), matching _relayout().
func _handle_stick_edit_input(event: InputEvent) -> void:
	if !stick_enabled() || !stick.visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if _stick_edit_finger == -1 \
					&& stick.get_global_rect().has_point(event.position):
				_stick_edit_finger = event.index
				_on_dpad_drag(Vector2.ZERO, null, "touch_off_dpad")
		elif event.index == _stick_edit_finger:
			_stick_edit_finger = -1
			_save_offsets()
	elif event is InputEventScreenDrag:
		if event.index == _stick_edit_finger:
			_on_dpad_drag(event.relative, null, "touch_off_dpad")
	elif event is InputEventMouseButton \
			&& event.button_index == MOUSE_BUTTON_LEFT \
			&& event.device != InputEvent.DEVICE_ID_EMULATION:
		if event.is_pressed():
			if !_stick_edit_mouse \
					&& stick.get_global_rect().has_point(event.position):
				_stick_edit_mouse = true
				_on_dpad_drag(Vector2.ZERO, null, "touch_off_dpad")
		elif _stick_edit_mouse:
			_stick_edit_mouse = false
			_save_offsets()
	elif event is InputEventMouseMotion \
			&& event.device != InputEvent.DEVICE_ID_EMULATION \
			&& _stick_edit_mouse:
		_on_dpad_drag(event.relative, null, "touch_off_dpad")


func _physics_process(_delta: float) -> void:
	var paused := get_tree().paused
	var blocked := _pause_open_blocked()
	var embedded := _hybrid_scene && _embedded_menu_active()
	var chooser := _chooser_active()
	var popup := _popup_active()
	if paused != _last_tree_paused \
			|| blocked != _last_pause_blocked \
			|| embedded != _last_embedded_menu \
			|| chooser != _last_chooser_active \
			|| popup != _last_popup_active:
		_last_tree_paused = paused
		_last_pause_blocked = blocked
		_last_embedded_menu = embedded
		_last_chooser_active = chooser
		_last_popup_active = popup
		_refresh_state()
	_process_stick_digital()


func refresh_popup_cache() -> void:
	_cached_windows = MobileCompat.collect_windows(get_tree().root)
	_last_popup_active = _popup_active()


func begin_import_block() -> void:
	if _import_block:
		return
	_import_block = true
	_import_prev_paused = get_tree().paused
	get_tree().paused = true
	_refresh_state()


func end_import_block() -> void:
	if !_import_block:
		return
	_import_block = false
	get_tree().paused = _import_prev_paused
	_refresh_state()


func import_block_active() -> bool:
	return _import_block


func _popup_active() -> bool:
	for w in _cached_windows:
		if is_instance_valid(w) && w.visible:
			return true
	return false


func _chooser_active() -> bool:
	var cs := Scenes.current_scene
	if cs == null || !cs.scene_file_path.begins_with(INTRO_PATH_PREFIX):
		return false
	for child in cs.get_children():
		if child.scene_file_path == TWEAK_PRESETS_PATH:
			return true
	return false


func _pause_open_blocked() -> bool:
	var pause_ctrl = Scenes.custom_scenes.get(&"pause")
	return pause_ctrl != null && pause_ctrl.open_blocked


func _in_skin_test_room() -> bool:
	var cs := Scenes.current_scene
	return cs != null && cs.get(&"_skin_test_level") == true


func _embedded_menu_active() -> bool:
	for c in _cached_menu_controllers:
		if is_instance_valid(c) && c.focused && c.is_visible_in_tree():
			return true
	return false


func _build_controls() -> void:
	for i in GAME_MOVE_ACTIONS.size():
		var btn := ActionButton.new([GAME_MOVE_ACTIONS[i]], "", 18)
		btn.rounded_square = true
		match i:
			0: btn.arrow_direction = Vector2.LEFT
			1: btn.arrow_direction = Vector2.RIGHT
			2: btn.arrow_direction = Vector2.UP
			3: btn.arrow_direction = Vector2.DOWN
		dpad_buttons.append(btn)
		add_child(btn)

	jump_btn = ActionButton.new([&"m_jump"], "JUMP")
	fire_btn = ActionButton.new([&"m_run", &"m_attack"], "RUN")
	extra_btn = ActionButton.new([&"m_extra", &"ui_select"], "EXTRA")
	pause_btn = ActionButton.new([], "| |")
	pause_btn.touch_pressed.connect(_press_pause)

	stick = VirtualJoystick.new()
	stick.joystick_mode = VirtualJoystick.JOYSTICK_FIXED
	stick.visibility_mode = VirtualJoystick.VISIBILITY_ALWAYS
	stick.deadzone_ratio = 0.15
	stick.action_left = DUMMY_ACTIONS[0]
	stick.action_right = DUMMY_ACTIONS[1]
	stick.action_up = DUMMY_ACTIONS[2]
	stick.action_down = DUMMY_ACTIONS[3]
	add_child(stick)
	for action in DUMMY_ACTIONS:
		if !InputMap.has_action(action):
			InputMap.add_action(action)

	jump_btn.drag_moved.connect(_on_drag.bind(jump_btn, "touch_off_jump"))
	fire_btn.drag_moved.connect(_on_drag.bind(fire_btn, "touch_off_fire"))
	extra_btn.drag_moved.connect(_on_drag.bind(extra_btn, "touch_off_extra"))
	pause_btn.drag_moved.connect(_on_drag.bind(pause_btn, "touch_off_pause"))
	for i in dpad_buttons.size():
		dpad_buttons[i].drag_moved.connect(
			_on_dpad_drag.bind(dpad_buttons[i], "touch_off_dpad")
		)

	for btn in [jump_btn, fire_btn, extra_btn, pause_btn]:
		btn.drag_finished.connect(_save_offsets)
	for btn in dpad_buttons:
		btn.drag_finished.connect(_save_offsets)

	for btn in [jump_btn, fire_btn, extra_btn, pause_btn]:
		add_child(btn)


# --- settings accessors ---

func touch_enabled() -> bool:
	return SettingsManager.get_custom_setting("touch_enabled", true)


func ui_scale() -> float:
	return clampf(SettingsManager.get_custom_setting("touch_scale", 1.0), 0.5, 2.5)


func ui_opacity() -> float:
	return clampf(SettingsManager.get_custom_setting("touch_opacity", 0.6), 0.1, 1.0)


func apply_settings() -> void:
	_relayout()


func stick_enabled() -> bool:
	return SettingsManager.get_custom_setting("touch_stick", false)


func set_stick_mode(on: bool) -> void:
	SettingsManager.set_custom_setting("touch_stick", on)
	if on:
		SettingsManager.set_custom_setting("touch_dual_mode", false)
	SettingsManager.save_settings()
	_refresh_state()


func use_dual_mode() -> bool:
	return stick_enabled() && SettingsManager.get_custom_setting("touch_dual_mode", false)


func set_dual_mode(on: bool) -> void:
	SettingsManager.set_custom_setting("touch_dual_mode", on)
	if on:
		SettingsManager.set_custom_setting("touch_stick", true)
	SettingsManager.save_settings()
	_refresh_state()


func _current_ui_mode() -> bool:
	return _state == ViewState.MENU || (
		get_tree().paused
		|| (_pause_open_blocked() && !_in_skin_test_room())
		|| (_hybrid_scene && _embedded_menu_active())
	)


func _release_stick() -> void:
	for a in DUMMY_ACTIONS:
		if Input.is_action_pressed(a):
			Input.action_release(a)
	var real := UI_MOVE_ACTIONS if _current_ui_mode() else GAME_MOVE_ACTIONS
	for i in 4:
		if _stick_prev_ui[i]:
			MobileCompat.inject_action(real[i], false)
			_stick_prev_ui[i] = false


func _stick_analog() -> Vector2:
	return Vector2(
		Input.get_action_strength(DUMMY_ACTIONS[1]) - Input.get_action_strength(DUMMY_ACTIONS[0]),
		Input.get_action_strength(DUMMY_ACTIONS[3]) - Input.get_action_strength(DUMMY_ACTIONS[2])
	)


func _snap_octant(vec: Vector2) -> int:
	if vec.length_squared() < STICK_DIGITAL_THRESHOLD * STICK_DIGITAL_THRESHOLD:
		return -1
	var ang := atan2(vec.y, vec.x)
	var idx := int(round(ang / (PI / 4.0)))
	return ((idx % 8) + 8) % 8


func _digitals_for_octant(idx: int) -> Array:
	if idx < 0:
		return [false, false, false, false]
	match idx:
		0: return [false, true, false, false]
		1: return [false, true, false, true]
		2: return [false, false, false, true]
		3: return [true, false, false, true]
		4: return [true, false, false, false]
		5: return [true, false, true, false]
		6: return [false, false, true, false]
		7: return [false, true, true, false]
	return [false, false, false, false]


func _process_stick_digital() -> void:
	if !stick_enabled() || edit_mode || !stick.visible:
		_release_stick()
		return
	var want := _digitals_for_octant(_snap_octant(_stick_analog()))
	var real := UI_MOVE_ACTIONS if _current_ui_mode() else GAME_MOVE_ACTIONS
	for i in 4:
		if want[i] != _stick_prev_ui[i]:
			MobileCompat.inject_action(real[i], want[i])
			_stick_prev_ui[i] = want[i]


func set_layout_edit(on: bool) -> void:
	if edit_mode == on:
		return
	edit_mode = on
	_stick_edit_finger = -1
	_stick_edit_mouse = false
	if on:
		for btn in _all_buttons():
			btn.force_release()
		_release_stick()
	_last_device_was_touch = true
	layout_edit_changed.emit(on)
	_refresh_state()


func reset_layout() -> void:
	for key in OFFSET_KEYS:
		SettingsManager.set_custom_setting(key, null)
	SettingsManager.save_settings()
	_load_offsets()
	_relayout()


func _all_buttons() -> Array:
	var out := []
	out.append_array(dpad_buttons)
	out.append_array([jump_btn, fire_btn, extra_btn, pause_btn])
	return out


# --- offsets ---

func _load_offsets() -> void:
	for key in OFFSET_KEYS:
		var raw: Variant = SettingsManager.get_custom_setting(key, null)
		if raw is Array && raw.size() == 2 \
				&& raw[0] is float && raw[1] is float:
			_offsets[key] = Vector2(raw[0], raw[1])
		else:
			_offsets[key] = Vector2.ZERO


func _on_dpad_drag(delta: Vector2, _btn, key: String) -> void:
	if !_drag_base.has(key):
		_drag_base[key] = {pos = _dpad_anchor, off = _offsets[key]}
	_dpad_anchor += delta
	_clamp_anchor()
	var md := _min_dim()
	_offsets[key] = _drag_base[key].off + (_dpad_anchor - _drag_base[key].pos) / md
	_relayout()


func _clamp_anchor() -> void:
	var win := DisplayServer.window_get_size()
	var ds := ds_size()
	_dpad_anchor.x = clampf(_dpad_anchor.x, ds * 1.0, win.x - ds * 1.0)
	_dpad_anchor.y = clampf(_dpad_anchor.y, ds * 1.0, win.y - ds * 1.0)


func _on_drag(delta: Vector2, btn, key: String) -> void:
	if !_drag_base.has(key):
		_drag_base[key] = {pos = btn.position, off = _offsets[key]}
	btn.position += delta
	_snap_to_axes(btn)
	_clamp_node(btn, btn.size.x)
	var md := _min_dim()
	_offsets[key] = _drag_base[key].off + (btn.position - _drag_base[key].pos) / md


## Snaps a dragged action button to the center axes of the other right-side
## buttons (jump/fire/extra), so their centers can be aligned
## horizontally or vertically in the layout editor.
func _snap_to_axes(btn) -> void:
	var threshold := maxf(12.0, _min_dim() * 0.02)
	for other in [jump_btn, fire_btn, extra_btn]:
		if other == btn || !is_instance_valid(other):
			continue
		var o_center: Vector2 = other.position + other.size * 0.5
		var center: Vector2 = btn.position + btn.size * 0.5
		if absf(center.x - o_center.x) < threshold:
			btn.position.x = o_center.x - btn.size.x * 0.5
		if absf(center.y - o_center.y) < threshold:
			btn.position.y = o_center.y - btn.size.y * 0.5


func _save_offsets() -> void:
	_drag_base.clear()
	for key in OFFSET_KEYS:
		var off: Vector2 = _offsets[key]
		SettingsManager.set_custom_setting(key, [off.x, off.y])
	SettingsManager.save_settings()


func _min_dim() -> float:
	var win := DisplayServer.window_get_size()
	return maxf(minf(win.x, win.y), 1.0)


func _clamp_node(node, size_hint: float) -> void:
	var win := DisplayServer.window_get_size()
	node.position.x = clampf(node.position.x, -size_hint * 0.4, win.x - size_hint * 0.6)
	node.position.y = clampf(node.position.y, -size_hint * 0.4, win.y - size_hint * 0.6)


func ds_size() -> float:
	return _min_dim() * ui_scale() * 0.125


# --- layout & visibility ---

func _compute_insets() -> void:
	var win := Vector2(DisplayServer.window_get_size())
	var sa := DisplayServer.get_display_safe_area()
	var left := maxf(sa.position.x, 0.0)
	var top := maxf(sa.position.y, 0.0)
	var right := maxf(win.x - sa.position.x - sa.size.x, 0.0)
	var bottom := maxf(win.y - sa.position.y - sa.size.y, 0.0)
	_insets = Rect2(left, top, right, bottom)


func _relayout() -> void:
	_compute_insets()
	var s := ui_scale()
	var opacity := ui_opacity()
	var win := DisplayServer.window_get_size()
	var unit := minf(win.x, win.y) * s
	var l := _insets.position.x + unit * 0.03
	var t := _insets.position.y + unit * 0.03
	var r := _insets.size.x + unit * 0.03
	var b := _insets.size.y + unit * 0.04

	var ds := unit * 0.125
	var gap := unit * 0.014
	_default_positions.dpad = Vector2(l + ds * 1.55, win.y - b - ds * 1.55)
	_dpad_anchor = _default_positions.dpad + _offsets.touch_off_dpad * minf(win.x, win.y)
	var offsets := [
		Vector2(-(ds + gap), 0),
		Vector2(ds + gap, 0),
		Vector2(0, -(ds + gap)),
		Vector2(0, ds + gap),
	]
	for i in dpad_buttons.size():
		dpad_buttons[i].size = Vector2.ONE * ds
		dpad_buttons[i].position = _dpad_anchor + offsets[i] - Vector2.ONE * ds * 0.5
		dpad_buttons[i].font_size = int(ds * 0.26)
		dpad_buttons[i].queue_redraw()

	var stick_size := ds * 2.6
	stick.joystick_size = stick_size
	stick.tip_size = ds * 1.1
	stick.size = Vector2.ONE * stick_size
	stick.position = _dpad_anchor - Vector2.ONE * stick_size * 0.5

	var az := unit * 0.155
	_default_positions[jump_btn] = Vector2(win.x - r - az, win.y - b - az)
	jump_btn.size = Vector2.ONE * az
	jump_btn.position = _default_positions[jump_btn] + _offsets.touch_off_jump * minf(win.x, win.y)
	jump_btn.font_size = int(az * 0.24)

	_default_positions[fire_btn] = Vector2(win.x - r - az - az * 1.12, win.y - b - az)
	fire_btn.size = Vector2.ONE * az
	fire_btn.position = _default_positions[fire_btn] + _offsets.touch_off_fire * minf(win.x, win.y)
	fire_btn.font_size = int(az * 0.22)

	var ez := unit * 0.13
	_default_positions[extra_btn] = Vector2(
		win.x - r - az * 0.5 - ez * 0.5, win.y - b - az - ez * 1.18
	)
	extra_btn.size = Vector2.ONE * ez
	extra_btn.position = _default_positions[extra_btn] + _offsets.touch_off_extra * minf(win.x, win.y)
	extra_btn.font_size = int(ez * 0.22)

	var pz := maxf(unit * 0.075, 48.0)
	_default_positions[pause_btn] = Vector2(win.x - r - pz, t)
	pause_btn.size = Vector2.ONE * pz
	pause_btn.position = _default_positions[pause_btn] + _offsets.touch_off_pause * minf(win.x, win.y)
	pause_btn.font_size = int(pz * 0.34)

	for entry in [jump_btn, fire_btn, extra_btn, pause_btn]:
		entry.queue_redraw()

	for ctrl in [jump_btn, fire_btn, extra_btn, pause_btn]:
		ctrl.modulate.a = 1.0 if edit_mode else opacity
	for btn in dpad_buttons:
		btn.modulate.a = 1.0 if edit_mode else opacity


func press_pause(silent: bool = false) -> void:
	_press_pause(silent)


func _press_pause(silent: bool = false) -> void:
	var cs := Scenes.current_scene
	var stage_like := cs != null && (cs is Stage2D || cs is Map2D)
	if !stage_like && _state != ViewState.PAUSE_ONLY:
		return
	if _hybrid_scene && _embedded_menu_active():
		return
	var pause_ctrl = Scenes.custom_scenes.get(&"pause")
	if pause_ctrl == null || pause_ctrl.open_blocked:
		return
	if &"game_over" in Scenes.custom_scenes \
			&& Scenes.custom_scenes.game_over.opened:
		return
	pause_ctrl.toggle(false, silent)


func _on_scene_signal(_to: Node = null) -> void:
	_refresh_state.call_deferred()


func _on_pause_signal() -> void:
	_refresh_state.call_deferred()


func _refresh_state() -> void:
	_state = _classify_scene()
	_cache_menu_controllers()
	_cached_windows = MobileCompat.collect_windows(get_tree().root)
	_relayout()
	_sync_buttons()


func _cache_menu_controllers() -> void:
	_hybrid_scene = false
	_cached_menu_controllers.clear()
	var cs := Scenes.current_scene
	if cs == null:
		return
	for p in HYBRID_MENU_PATHS:
		if cs.scene_file_path == p:
			_hybrid_scene = true
			break
	if !_hybrid_scene:
		return
	var stack: Array[Node] = [cs]
	while !stack.is_empty():
		var node: Node = stack.pop_back()
		for child in node.get_children():
			stack.append(child)
		if node is MenuItemsController:
			_cached_menu_controllers.append(node)


func _classify_scene() -> int:
	var cs := Scenes.current_scene
	if cs == null:
		return ViewState.MENU
	var path := cs.scene_file_path
	if path.begins_with(INTRO_PATH_PREFIX):
		if _chooser_active():
			return ViewState.MENU
		return ViewState.HIDDEN
	for p in PAUSE_ONLY_PATHS:
		if path.begins_with(p):
			return ViewState.PAUSE_ONLY
	for p in FORCE_UI_PATHS:
		if path == p:
			return ViewState.MENU
	for p in FORCE_ACTION_PATHS:
		if path.begins_with(p):
			return ViewState.STAGE
	if cs is Stage2D:
		return ViewState.STAGE
	if cs is Map2D:
		return ViewState.MAP
	return ViewState.MENU


func _sync_buttons() -> void:
	var active := (
		MobileCompat.is_touch_device()
		&& touch_enabled()
		&& (_last_device_was_touch || edit_mode)
	)
	if _state == ViewState.HIDDEN || _popup_active() || _import_block:
		for btn in _all_buttons():
			btn.force_release()
			btn.visible = false
		_release_stick()
		stick.visible = false
		stick.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return
	var paused := (
		get_tree().paused
		|| (_pause_open_blocked() && !_in_skin_test_room())
		|| (_hybrid_scene && _embedded_menu_active())
	)
	var ui_mode := _state == ViewState.MENU || paused
	var use_stick := stick_enabled()
	var dual := use_dual_mode()

	for i in dpad_buttons.size():
		var target: Array = [] if edit_mode else [move_action_for(ui_mode, i)]
		var dpad_active := false
		if !use_stick || (dual && ui_mode):
			dpad_active = active && _state != ViewState.PAUSE_ONLY
		dpad_buttons[i].visible = dpad_active
		dpad_buttons[i].input_locked = edit_mode
		if dpad_buttons[i].actions != target:
			dpad_buttons[i].set_actions(target)

	if dual:
		stick.visible = active && _state != ViewState.PAUSE_ONLY && !ui_mode
	else:
		stick.visible = active && _state != ViewState.PAUSE_ONLY && use_stick
	var stick_consumes_input := (
		stick.visible
		&& _state != ViewState.PAUSE_ONLY
		&& !(dual && ui_mode)
	)
	if edit_mode:
		# Disable the built-in stick handling so presses can be used
		# for repositioning in the layout editor instead.
		stick.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		stick.mouse_filter = (
			Control.MOUSE_FILTER_STOP if stick_consumes_input
			else Control.MOUSE_FILTER_IGNORE
		)
	stick.modulate.a = 1.0 if edit_mode else ui_opacity()

	jump_btn.input_locked = edit_mode
	if edit_mode:
		jump_btn.set_actions([])
		jump_btn.set_label("JUMP")
	elif ui_mode && active:
		jump_btn.set_actions([&"ui_accept"])
		jump_btn.set_label("A")
	else:
		jump_btn.set_actions([&"m_jump", &"ui_accept"])
		jump_btn.set_label("JUMP")
	var actions_visible := (
		active
		&& (edit_mode || ui_mode || _state != ViewState.MENU)
		&& _state != ViewState.PAUSE_ONLY
	)
	jump_btn.visible = actions_visible

	fire_btn.visible = actions_visible
	fire_btn.input_locked = edit_mode
	if edit_mode:
		fire_btn.set_actions([])
		fire_btn.set_label("FIRE")
	elif ui_mode && active:
		fire_btn.set_actions([&"ui_cancel"])
		fire_btn.set_label("B")
	else:
		var fire_actions: Array = [&"m_run", &"m_attack"]
		if !_in_skin_test_room():
			fire_actions.append(&"ui_cancel")
		fire_btn.set_actions(fire_actions)
		fire_btn.set_label("FIRE")

	extra_btn.visible = actions_visible
	extra_btn.input_locked = edit_mode
	if edit_mode:
		extra_btn.set_actions([])

	pause_btn.visible = active && (
		edit_mode
		|| _state == ViewState.STAGE
		|| _state == ViewState.MAP
		|| _state == ViewState.PAUSE_ONLY
	)
	pause_btn.input_locked = edit_mode
	if edit_mode:
		pause_btn.set_actions([])


func move_action_for(ui_mode: bool, index: int) -> StringName:
	return (UI_MOVE_ACTIONS if ui_mode else GAME_MOVE_ACTIONS)[index]
