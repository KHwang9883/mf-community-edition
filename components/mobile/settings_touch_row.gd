extends MenuSelection
## Touch settings entry shown inside the Options "Controls" screen submenu.

const ROW_FONT := preload("res://engine/fonts/font_variations/smb_variation.tres")
const TEXT_GRADIENT := preload("res://components/mobile/text_gradient.gdshader")
const TOGGLE_SOUND := preload("res://engine/scenes/main_menu/sounds/change.wav")

## "PRESS ENTER" prompt textures, taken from the same sheet the other menu
## entries use. Touch input shows it as well so the screens read the same.
const PRESS_ENTER_TEXTURE := preload("res://engine/scenes/main_menu/textures/press_enter.png")
const PRESS_REGION := Rect2(0, 0, 96, 30)
const ENTER_REGION := Rect2(102, 0, 94, 30)

const SIZE_PRESETS: Array[float] = [1.0, 1.25, 1.5, 1.75, 2.0, 2.5]
const OPACITY_PRESETS: Array[float] = [0.3, 0.45, 0.6, 0.75, 0.9]

## 通用开关贴图（与 Options 里的 AutoPause / XScroll 等布尔项同一张图）：
## 上半是 OFF，下半是 ON。
const ON_OFF_TEXTURE := preload("res://engine/scenes/main_menu/textures/on_off.png")
const ON_OFF_REGION := Rect2(0, 0, 64, 36)
const ON_OFF_ROW_HEIGHT := 36.0

const COLOR_NAME := Color(1, 1, 1, 1)
const COLOR_OUTLINE := Color(0.156863, 0.156863, 0.156863, 0.784314)
const FONT_SIZE := 28

## Bevel gradients sampled from the pre-rendered label textures (controls.png /
## controls_main.png): bright at the top, darker at the bottom.
const YELLOW_GRADIENT: Array[Color] = [Color(1, 1, 0.353), Color(0.557, 0.498, 0)]
const BLUE_GRADIENT: Array[Color] = [Color(0.918, 0.918, 1), Color(0.349, 0.349, 0.573)]
const RED_GRADIENT: Array[Color] = [Color(1, 0.667, 0.667), Color(0.718, 0.251, 0.251)]

## Move-input styles, in the order of TouchControls.MOVE_MODE_*
const MOVE_MODE_NAMES: Array[String] = ["D-PAD", "STICK", "HYBRID"]

@export var kind := "size"

var _name_label: Label
var _value_label: Label
var _on_off_rect: TextureRect
var _press_hint: HBoxContainer


func _ready() -> void:
	_name_label = _make_label(COLOR_NAME)
	_name_label.text = _row_name()
	_name_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_apply_gradient(_name_label, _name_gradient())
	add_child(_name_label)

	if kind == "layout":
		_press_hint = make_press_enter_hint()
		add_child(_press_hint)

	if kind == "separate":
		# 布尔项用 Options 里的通用 ON/OFF 贴图，而不是文字。
		var atlas := AtlasTexture.new()
		atlas.atlas = ON_OFF_TEXTURE
		atlas.region = ON_OFF_REGION
		_on_off_rect = TextureRect.new()
		_on_off_rect.texture = atlas
		_on_off_rect.stretch_mode = TextureRect.STRETCH_KEEP
		_on_off_rect.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
		_on_off_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		add_child(_on_off_rect)
	else:
		_value_label = _make_label(COLOR_NAME)
		_value_label.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
		add_child(_value_label)

	_refresh_label()
	TouchControls.layout_edit_changed.connect(_on_layout_edit_changed)


## Builds the right-hand "PRESS ENTER" prompt box shared by the menu entries.
## Focus is handled by the caller, which mirrors the row name's blink onto it.
static func make_press_enter_hint() -> HBoxContainer:
	var box := HBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_child(_make_prompt_rect(PRESS_REGION))
	box.add_child(_make_prompt_rect(ENTER_REGION))
	return box


static func _make_prompt_rect(region: Rect2) -> TextureRect:
	var atlas := AtlasTexture.new()
	atlas.atlas = PRESS_ENTER_TEXTURE
	atlas.region = region
	var rect := TextureRect.new()
	rect.texture = atlas
	rect.stretch_mode = TextureRect.STRETCH_KEEP
	rect.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
	rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return rect


## Keeps the prompt as visible as the row name, which the menu blinker fades.
func _process(_delta: float) -> void:
	if _press_hint:
		_press_hint.modulate.a = _name_label.modulate.a if focused else 0.0


func _make_label(color: Color) -> Label:
	var label := Label.new()
	label.uppercase = true
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	label.add_theme_font_override(&"font", ROW_FONT)
	label.add_theme_font_size_override(&"font_size", FONT_SIZE)
	label.add_theme_color_override(&"font_color", color)
	label.add_theme_color_override(&"font_outline_color", COLOR_OUTLINE)
	label.add_theme_constant_override(&"outline_size", 6)
	return label


func _apply_gradient(label: Label, gradient: Array[Color]) -> void:
	var material := ShaderMaterial.new()
	material.shader = TEXT_GRADIENT
	material.set_shader_parameter(&"gradient_top", gradient[0])
	material.set_shader_parameter(&"gradient_bottom", gradient[1])
	label.material = material


func _name_gradient() -> Array[Color]:
	match kind:
		"opacity", "stick", "separate":
			return BLUE_GRADIENT
		"reset":
			return RED_GRADIENT
	return YELLOW_GRADIENT


func _on_layout_edit_changed(_editing: bool) -> void:
	if kind == "layout":
		_refresh_label()


func _row_name() -> String:
	match kind:
		"opacity":
			return "TOUCH OPACITY"
		"layout":
			return "TOUCH LAYOUT"
		"reset":
			return "RESET TOUCH LAYOUT"
		"stick":
			return "MOVE INPUT"
		"separate":
			return "SEPARATE D-PAD"
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
			# The prompt and the editing state share the right-hand slot.
			var editing := TouchControls.edit_mode
			_value_label.text = "EDITING" if editing else ""
			_value_label.visible = editing
			_press_hint.visible = !editing
		"reset":
			_value_label.text = ""
		"stick":
			_value_label.text = MOVE_MODE_NAMES[TouchControls.move_mode()]
		"separate":
			(_on_off_rect.texture as AtlasTexture).region.position.y = (
				ON_OFF_ROW_HEIGHT if TouchControls.dpad_free_setting() else 0.0
			)


func _play_toggle_sound() -> void:
	var sfx = CharacterManager.get_sound_replace(TOGGLE_SOUND, TOGGLE_SOUND, "menu_toggle", false)
	Audio.play_1d_sound(sfx, true, { "ignore_pause": true, "bus": "1D Sound" })


func _cycle(direction: int) -> void:
	match kind:
		"layout":
			TouchControls.set_layout_edit(!TouchControls.edit_mode)
			_play_toggle_sound()
		"stick":
			# Cycle order: D-PAD -> STICK -> HYBRID. Any direction follows this
			# loop so the sequence never gets confusing.
			var mode := wrapi(TouchControls.move_mode() + direction, 0, MOVE_MODE_NAMES.size())
			TouchControls.set_move_mode(mode)
			_play_toggle_sound()
		"separate":
			# 只有开/关两档，任何方向都按循环切换处理。
			_toggle_separate()
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


func _toggle_separate() -> void:
	TouchControls.set_dpad_free(!TouchControls.dpad_free_setting())
	_play_toggle_sound()
	_refresh_label()


func _handle_focused(focus) -> void:
	super(focus)
	if focus:
		_refresh_label()


func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	if kind == "reset":
		_confirm_reset()
	elif kind == "separate":
		_toggle_separate()
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


func _physics_process(_delta: float) -> void:
	if !focused || !get_parent().focused:
		return
	if !get_window().has_focus():
		return
	if kind == "separate":
		# 只有左右键切换这个开关，确认键与其它 ON/OFF 设置一样不响应。
		if Input.is_action_just_pressed(&"ui_right") \
				|| Input.is_action_just_pressed(&"ui_left"):
			_toggle_separate()
		return
	if kind == "layout" || kind == "reset":
		if Input.is_action_just_pressed(trigger_action) \
				|| Input.is_action_just_pressed(&"ui_select"):
			_handle_select(false)
		if kind == "layout" && TouchControls.edit_mode \
				&& Input.is_action_just_pressed(&"ui_select"):
			TouchControls.reset_layout()
			_refresh_label()
		return
	if Input.is_action_just_pressed(&"ui_right"):
		_cycle(1)
	elif Input.is_action_just_pressed(&"ui_left"):
		_cycle(-1)
