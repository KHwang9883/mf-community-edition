extends MenuSelection

const SELECT_FAILURE = preload("res://engine/components/ui/_sounds/select_failure.wav")

@export_node_path("MenuItemsController") var move_to_path: NodePath
@export_node_path("MenuSelector") var menu_selector_path: NodePath
@export var reset_to: int = 0
@export var show_desc_bool: bool = false
@export_multiline var tweak_description_text: String
@export var is_blocked: bool

@onready var valu = get_node_or_null(^"Value")
@onready var camera_2d: Camera2D = $"../../Camera2D"
@onready var move_to: MenuItemsController = get_node_or_null(move_to_path)
@onready var selector_to: MenuSelector = get_node_or_null(menu_selector_path)
var _timer: float

signal selection_entered

func _ready() -> void:
	if valu:
		valu.modulate.a = 0.0
		_template = valu.text
		_update_text()
		SettingsManager.settings_saved.connect(_update_text)

func _physics_process(delta: float) -> void:
	super(delta)
	if focused && get_parent().focused:
		if Input.is_action_just_pressed(&"ui_select") && tweak_description_text:
			$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)
	
	if !valu:
		return
	if focused && !is_blocked:
		_timer += delta * 10
		valu.modulate.a = min((cos(_timer) / 2.5) + 0.6, 1.0)
	else:
		valu.modulate.a = 0.0

func _handle_focused(focus) -> void:
	super(focus)
	if !focus: return
	if tweak_description_text:
		$"../..".emit_signal(&"_tweak_desc", get_parent())

func _handle_right_click() -> void:
	if focused && get_parent().focused && tweak_description_text:
		$"../..".emit_signal(&"_show_desc", tweak_description_text, $Label.text)

func _handle_select(mouse_input: bool = false) -> void:
	if is_blocked:
		var _sfx = CharacterManager.get_sound_replace(SELECT_FAILURE, SELECT_FAILURE, "menu_failure", false)
		Audio.play_1d_sound(_sfx, true, { "ignore_pause": true, "bus": "1D Sound" })
		return
	super(mouse_input)
	_select_category()

func _select_category() -> void:
	selection_entered.emit()
	get_parent().position.x = 1000
	get_parent().reset_physics_interpolation()
	move_to.position.x = 168
	move_to.reset_physics_interpolation()
	get_parent().focused = false
	Scenes.current_scene.get_node("Tweaks/Label2").visible = false
	var old_selector = camera_2d.selector
	camera_2d.menu_controller = move_to
	camera_2d.selector = selector_to
	camera_2d.update_limit()
	camera_2d.reset_physics_interpolation()
	await get_tree().physics_frame
	
	if reset_to >= 0:
		get_parent().move_selector(reset_to, true)
	elif is_instance_valid(old_selector):
		get_parent().move_selector(old_selector._current_item_index, true)
	move_to.focused = true
	get_parent().focused = false
	if show_desc_bool:
		Scenes.current_scene.get_node("Tweaks/Label2").visible = true

var _template: String
func _update_text() -> void:
	var _events: Array[InputEvent] = InputMap.action_get_events(&"ui_accept")
	var _event: String = "enter"
	var _temp: String
	for i in _events:
		if i is InputEventKey:
			_temp = i.as_text().get_slice(' (', 0)
			#if SettingsManager.device_keyboard:
			_event = _temp
			break
		#elif i is InputEventJoypadButton:
		#	_temp = "Joy " + str(i.button_index)
		if _temp: _event = _temp
	
	valu.text = _template % [_event]
