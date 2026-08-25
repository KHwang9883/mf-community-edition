extends MenuSelection

const ROW_FONT := preload("res://engine/fonts/font_variations/tweaks_font_var.tres")
const VALUE_FONT := preload("res://engine/fonts/font_variations/tweaks_font_title.tres")
const ARROW_FONT := preload("res://engine/fonts/junebug.ttf")
const TOGGLE_SOUND := preload("res://engine/scenes/main_menu/sounds/change.wav")

const SIZE_PRESETS: Array[float] = [1.0, 1.25, 1.5, 1.75, 2.0, 2.5]
const OPACITY_PRESETS: Array[float] = [0.3, 0.45, 0.6, 0.75, 0.9]

const COLOR_NAME := Color(1, 1, 1, 1)
const COLOR_VALUE := Color(0.79, 1, 0.909, 1)
const COLOR_OUTLINE := Color(0, 0, 0.329412, 1)
const COLOR_SHADOW := Color(0, 0, 0, 0.435294)

@export var kind := "size"

var _value_label: Label
var _arrow_l: Label
var _arrow_r: Label
var _arrow_base := {}
var _wobble_t := 0.0
var _timer := 0.0


func _ready() -> void:
	var name_label := _make_text_label(COLOR_NAME)
	name_label.text = _row_name()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(name_label)

	var value_box := HBoxContainer.new()
	value_box.size_flags_horizontal = Control.SIZE_SHRINK_END
	value_box.add_theme_constant_override(&"separation", 8)
	add_child(value_box)

	_arrow_l = _make_arrow(true)
	value_box.add_child(_arrow_l)

	_value_label = _make_text_label(COLOR_VALUE)
	_value_label.add_theme_font_override(&"font", VALUE_FONT)
	_refresh_label()
	value_box.add_child(_value_label)

	_arrow_r = _make_arrow(false)
	value_box.add_child(_arrow_r)

	_sync_arrows()
	TouchControls.layout_edit_changed.connect(_on_layout_edit_changed)


func _process(delta: float) -> void:
	if !is_instance_valid(_arrow_l) || !is_instance_valid(_arrow_r):
		return
	_wobble_t += delta
	for entry in [[_arrow_l, -3.0], [_arrow_r, 3.0]]:
		var arrow: Label = entry[0]
		if !arrow.visible:
			continue
		if !_arrow_base.has(arrow):
			_arrow_base[arrow] = arrow.position
			continue
		arrow.position.x = _arrow_base[arrow].x + sin(_wobble_t * 8.0) * entry[1]


func _invalidate_arrow_base() -> void:
	_arrow_base.clear()


func _on_layout_edit_changed(_editing: bool) -> void:
	if kind == "layout":
		_refresh_label()


func _make_text_label(color: Color) -> Label:
	var label := Label.new()
	label.uppercase = true
	label.add_theme_font_override(&"font", ROW_FONT)
	label.add_theme_font_size_override(&"font_size", 22)
	label.add_theme_color_override(&"font_color", color)
	label.add_theme_color_override(&"font_shadow_color", COLOR_SHADOW)
	label.add_theme_color_override(&"font_outline_color", COLOR_OUTLINE)
	label.add_theme_constant_override(&"line_spacing", 1)
	label.add_theme_constant_override(&"shadow_offset_x", 3)
	label.add_theme_constant_override(&"shadow_offset_y", 3)
	label.add_theme_constant_override(&"outline_size", 4)
	return label


func _make_arrow(left_side: bool) -> Label:
	var arrow := Label.new()
	arrow.name = &"ArrowL" if left_side else &"ArrowR"
	arrow.text = "<--" if left_side else "-->"
	arrow.uppercase = true
	arrow.add_theme_font_override(&"font", ARROW_FONT)
	arrow.add_theme_font_size_override(&"font_size", 13)
	arrow.add_theme_color_override(&"font_shadow_color", COLOR_SHADOW)
	arrow.add_theme_color_override(&"font_outline_color", COLOR_OUTLINE)
	arrow.add_theme_constant_override(&"line_spacing", 1)
	arrow.add_theme_constant_override(&"shadow_offset_x", 3)
	arrow.add_theme_constant_override(&"shadow_offset_y", 3)
	arrow.add_theme_constant_override(&"outline_size", 4)
	arrow.visible = false
	return arrow


func _row_name() -> String:
	match kind:
		"opacity":
			return "TOUCH OPACITY"
		"layout":
			return "TOUCH LAYOUT"
		"reset":
			return "RESET TOUCH LAYOUT"
	return "TOUCH SIZE"


func _setting_key() -> StringName:
	return &"touch_scale" if kind == "size" else &"touch_opacity"


func _presets() -> Array[float]:
	return SIZE_PRESETS if kind == "size" else OPACITY_PRESETS


func _default_value() -> float:
	return 1.0 if kind == "size" else 0.6


func _current_value() -> float:
	return clampf(
		SettingsManager.get_custom_setting(_setting_key(), _default_value()),
		0.1,
		2.5
	)


func _refresh_label() -> void:
	match kind:
		"size":
			_value_label.text = "%.2fx" % _current_value()
		"opacity":
			_value_label.text = "%d%%" % roundi(_current_value() * 100)
		"layout":
			_value_label.text = ""
		"reset":
			_value_label.text = ""
	_invalidate_arrow_base.call_deferred()
	_sync_arrows()


func _sync_arrows() -> void:
	if !is_instance_valid(_arrow_l) || !is_instance_valid(_arrow_r):
		return
	var show: bool = (
		focused
		&& get_parent().focused
		&& kind != "reset"
		&& kind != "layout"
	)
	_arrow_l.visible = show
	_arrow_r.visible = show


func _play_toggle_sound() -> void:
	var sfx = CharacterManager.get_sound_replace(TOGGLE_SOUND, TOGGLE_SOUND, "menu_toggle", false)
	Audio.play_1d_sound(sfx, true, { "ignore_pause": true, "bus": "1D Sound" })


func _cycle(direction: int) -> void:
	match kind:
		"layout":
			TouchControls.set_layout_edit(!TouchControls.edit_mode)
			_play_toggle_sound()
		_:
			var presets := _presets()
			var idx := presets.find(_current_value())
			idx = wrapi(idx + direction, 0, presets.size())
			if idx < 0:
				idx = 0
			if presets[idx] == _current_value():
				return
			SettingsManager.set_custom_setting(_setting_key(), presets[idx])
			SettingsManager.save_settings()
			TouchControls.apply_settings()
			_play_toggle_sound()
	_refresh_label()


func _handle_focused(focus) -> void:
	super(focus)
	if focus:
		_refresh_label()
	else:
		_sync_arrows()


func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	if kind == "reset":
		_confirm_reset()
	else:
		_cycle(1)


func _confirm_reset() -> void:
	if get_tree() == null:
		return
	var dlg := ConfirmationDialog.new()
	dlg.title = "Reset touch layout"
	dlg.dialog_text = "Reset all touch button positions to default?"
	dlg.ok_button_text = "RESET"
	dlg.cancel_button_text = "CANCEL"
	dlg.confirmed.connect(_on_reset_confirmed)
	dlg.confirmed.connect(dlg.queue_free)
	dlg.canceled.connect(dlg.queue_free)
	dlg.close_requested.connect(dlg.queue_free)
	add_child(dlg)
	MobileCompat.scale_popup_window(dlg)
	TouchControls.refresh_popup_cache()
	dlg.popup_centered()


func _on_reset_confirmed() -> void:
	TouchControls.reset_layout()
	_play_toggle_sound()


func _physics_process(delta: float) -> void:
	if kind == "layout" || kind == "reset":
		var editing := kind == "layout" && TouchControls.edit_mode
		if focused && get_parent().focused && get_window().has_focus():
			_timer += delta * 10
			_value_label.modulate.a = min((cos(_timer) / 2.5) + 0.6, 1.0)
			var want := "BACK TO FINISH" if editing else "PRESS ENTER"
			if _value_label.text != want:
				_value_label.text = want
		elif editing:
			if _value_label.text != "BACK TO FINISH":
				_value_label.text = "BACK TO FINISH"
			_value_label.modulate.a = 1.0
		else:
			_value_label.modulate.a = 1.0
			if _value_label.text != "":
				_value_label.text = ""
	if !focused || !get_parent().focused:
		return
	if !get_window().has_focus():
		return
	if kind == "layout":
		if Input.is_action_just_pressed(trigger_action) \
				|| Input.is_action_just_pressed(&"ui_select"):
			_handle_select(false)
		if TouchControls.edit_mode && Input.is_action_just_pressed(&"ui_select"):
			TouchControls.reset_layout()
			_refresh_label()
		return
	if kind == "reset":
		if Input.is_action_just_pressed(trigger_action) \
				|| Input.is_action_just_pressed(&"ui_select"):
			_handle_select(false)
		return
	if Input.is_action_just_pressed(&"ui_right"):
		_cycle(1)
	elif Input.is_action_just_pressed(&"ui_left"):
		_cycle(-1)
