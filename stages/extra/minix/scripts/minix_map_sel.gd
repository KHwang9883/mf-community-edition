extends MenuSelection

const toggle_sound = preload("res://engine/scenes/main_menu/sounds/change.wav")

var value_template: String
var is_preview: bool = false
var tw: Tween

@onready var starter: Node2D = $"../.."
@onready var label: Label = $Label
@onready var minix_controls: MenuItemsController = $".."
@onready var selector: MenuSelector = $"../../Selector"
@onready var selector_2: MenuSelector = $"../../Selector2"
@onready var scores: VBoxContainer = $"../../VBoxContainer"
@onready var scores2: VBoxContainer = $"../../VBoxContainer2"
@onready var color_rect_2: ColorRect = $"../../ColorRect2"
@onready var enter_to_preview: Label = $"../../EnterToPreview"
@onready var old_enter_to_preview: String = enter_to_preview.text

@onready var _minix_logo_pos: Vector2 = color_rect_2.position
@onready var _scores_pos: Vector2 = scores.position

signal selection_changed
signal map_changed_to(map_id: int)
signal map_name_changed_to(map_name: String)

func _ready():
	value_template = label.text
	_update_string.call_deferred()


func _handle_select(mouse_input: bool = false) -> void:
	_toggle_preview()
	super(mouse_input)


func _physics_process(delta: float) -> void:
	super(delta)
	if (Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("ui_down")) && is_preview:
		_toggle_preview(true)
	
	enter_to_preview.self_modulate.a = 0.0
	
	if !focused: return
	enter_to_preview.self_modulate.a = 1.0
	
	if Input.is_action_just_pressed("ui_right"):
		var old_value = starter.map_id
		starter.map_id = clamp(old_value + 1, 0, starter.map_names.size() - 1)
		_toggled_option(old_value, starter.map_id)
		
	if Input.is_action_just_pressed("ui_left"):
		var old_value = starter.map_id
		starter.map_id = clamp(old_value - 1, 0, starter.map_names.size() - 1)
		_toggled_option(old_value, starter.map_id)


func _toggled_option(old_val, new_val) -> void:
	if old_val == new_val: return
	var _sfx = CharacterManager.get_sound_replace(toggle_sound, toggle_sound, "menu_toggle", false)
	Audio.play_1d_sound(_sfx, true, { "ignore_pause": true, "bus": "1D Sound" })
	_update_string()
	selection_changed.emit()
	map_changed_to.emit(new_val)


func _toggle_preview(interrupt: bool = false) -> void:
	is_preview = !is_preview
	selector.smooth_transition = !is_preview
	selector_2.smooth_transition = !is_preview
	enter_to_preview.text = "arrow keys to switch maps" if is_preview else old_enter_to_preview
	if tw && tw.is_valid(): tw.stop()
	tw = create_tween().set_parallel().set_speed_scale(2.0 if interrupt else 1.0)
	tw.tween_property(minix_controls, "position:y",
		284 + 200 if is_preview else 284, 0.5).set_trans(Tween.TRANS_SINE)
	tw.tween_property(minix_controls, "modulate:a", 0.0 if is_preview else 1.0, 0.5).set_trans(Tween.TRANS_LINEAR)
	tw.tween_property(color_rect_2, "position:y",
		_minix_logo_pos.y - 50 if is_preview else _minix_logo_pos.y, 0.5).set_trans(Tween.TRANS_LINEAR)
	tw.tween_property(color_rect_2, "modulate:a", 0.0 if is_preview else 1.0, 0.5).set_trans(Tween.TRANS_LINEAR)
	tw.tween_property(selector, "modulate:a", 0.0 if is_preview else 1.0, 0.5).set_trans(Tween.TRANS_LINEAR)
	tw.tween_property(selector_2, "modulate:a", 0.0 if is_preview else 1.0, 0.5).set_trans(Tween.TRANS_LINEAR)
	tw.tween_property(scores, "position:y",
		_scores_pos.y + 50 if is_preview else _scores_pos.y, 0.5).set_trans(Tween.TRANS_SINE)
	tw.tween_property(scores, "modulate:a", 0.0 if is_preview else 1.0, 0.5).set_trans(Tween.TRANS_LINEAR)
	tw.tween_property(scores2, "position:y",
		_scores_pos.y + 50 if is_preview else _scores_pos.y, 0.5).set_trans(Tween.TRANS_SINE)
	tw.tween_property(scores2, "modulate:a", 0.0 if is_preview else 1.0, 0.5).set_trans(Tween.TRANS_LINEAR)


func _update_string() -> void:
	var map_name = starter.map_names[starter.map_id]
	label.text = value_template % map_name
	map_name_changed_to.emit(map_name)
