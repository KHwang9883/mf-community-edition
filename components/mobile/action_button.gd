extends Control

signal touch_pressed
signal touch_released
signal drag_moved(delta: Vector2)
signal drag_finished

@export var label_text := ""
@export var font_size := 20
@export var arrow_direction := Vector2.ZERO
@export var rounded_square := false

const COLOR_IDLE_FILL := Color(1.0, 1.0, 1.0, 0.14)
const COLOR_IDLE_LINE := Color(1.0, 1.0, 1.0, 0.5)
const COLOR_DOWN_FILL := Color(1.0, 0.93, 0.55, 0.42)
const COLOR_DOWN_LINE := Color(1.0, 1.0, 1.0, 0.85)
const COLOR_TEXT := Color(1.0, 1.0, 1.0, 0.92)
const COLOR_SHADOW := Color(0.0, 0.0, 0.0, 0.55)

var actions: Array[StringName] = []
var input_locked := false
var locked_visual := false

var _touch_fingers: Dictionary = {}
var _mouse_down := false


func _init(p_actions: Array = [], p_label: String = "", p_font_size: int = 20) -> void:
	for action in p_actions:
		actions.append(action as StringName)
	label_text = p_label
	font_size = p_font_size
	mouse_filter = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func is_down() -> bool:
	return _mouse_down || !_touch_fingers.is_empty()


func set_actions(new_actions: Array) -> void:
	if is_down():
		for action in actions:
			Input.action_release(action)
			MobileCompat.inject_action(action, false)
	actions.clear()
	for action in new_actions:
		actions.append(action as StringName)
	queue_redraw()


func force_release() -> void:
	if !is_down():
		return
	_touch_fingers.clear()
	_mouse_down = false
	_apply_up()


func set_label(text: String) -> void:
	if label_text == text:
		return
	label_text = text
	queue_redraw()


func set_locked(locked: bool) -> void:
	if locked_visual == locked:
		return
	locked_visual = locked
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if TouchControls.edit_mode:
		_handle_edit_input(event)
		return
	if event is InputEventScreenTouch:
		if event.pressed && !input_locked:
			var was := is_down()
			_touch_fingers[event.index] = true
			if !was:
				_apply_down()
		elif !event.pressed && _touch_fingers.has(event.index):
			_touch_fingers.erase(event.index)
			if !is_down():
				_apply_up()
		accept_event()
	elif event is InputEventScreenDrag:
		accept_event()
	elif event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed && !_mouse_down && !input_locked:
			_mouse_down = true
			_apply_down()
		elif !event.pressed && _mouse_down:
			_mouse_down = false
			_apply_up()
		accept_event()


func _handle_edit_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_fingers[event.index] = true
		else:
			_touch_fingers.erase(event.index)
			if !is_down():
				drag_finished.emit()
		accept_event()
	elif event is InputEventScreenDrag:
		if !_touch_fingers.is_empty():
			drag_moved.emit(event.relative)
		accept_event()
	elif event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_mouse_down = true
		else:
			_mouse_down = false
			drag_finished.emit()
		accept_event()
	elif event is InputEventMouseMotion && is_down():
		drag_moved.emit(event.relative)
		accept_event()


func _apply_down() -> void:
	for action in actions:
		Input.action_press(action)
		MobileCompat.inject_action(action, true)
	queue_redraw()
	touch_pressed.emit()


func _apply_up() -> void:
	for action in actions:
		Input.action_release(action)
		MobileCompat.inject_action(action, false)
	queue_redraw()
	touch_released.emit()


func _draw() -> void:
	var down := is_down() || locked_visual
	var fill := COLOR_DOWN_FILL if down else COLOR_IDLE_FILL
	var line := COLOR_DOWN_LINE if down else COLOR_IDLE_LINE
	if rounded_square:
		var sb := StyleBoxFlat.new()
		sb.bg_color = fill
		sb.border_color = line
		sb.set_border_width_all(3)
		sb.set_corner_radius_all(int(minf(size.x, size.y) * 0.26))
		sb.draw(get_canvas_item(), Rect2(Vector2.ZERO, size))
	else:
		var center := size * 0.5
		var radius := minf(size.x, size.y) * 0.5 - 4.0
		draw_circle(center, radius, fill)
		draw_arc(center, radius - 1.5, 0.0, TAU, 64, line, 3.0, true)
	if arrow_direction != Vector2.ZERO:
		_draw_chevron()
	elif !label_text.is_empty():
		_draw_label()


func _draw_chevron() -> void:
	var dir := arrow_direction.normalized()
	var center := size * 0.5
	var r := minf(size.x, size.y) * 0.2
	var tip := center + dir * r * 0.75
	var back := center - dir * r * 0.75
	var side := dir.orthogonal() * r * 0.8
	var points := PackedVector2Array([back + side, tip, back - side])
	draw_polyline(points, COLOR_SHADOW, r * 0.42, true)
	draw_polyline(points, COLOR_TEXT, r * 0.3, true)


func _draw_label() -> void:
	var font := ThemeDB.fallback_font
	var pos := Vector2(0.0, size.y * 0.5 + font_size * 0.35)
	draw_string(
		font,
		pos + Vector2(2, 2),
		label_text,
		HORIZONTAL_ALIGNMENT_CENTER,
		size.x,
		font_size,
		COLOR_SHADOW
	)
	draw_string(
		font,
		pos,
		label_text,
		HORIZONTAL_ALIGNMENT_CENTER,
		size.x,
		font_size,
		COLOR_TEXT
	)
