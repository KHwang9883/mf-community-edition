extends MenuSelection

@onready var valu = get_node_or_null(^"Value")
var _timer: float
@onready var skin_room: CanvasLayer = $"../../SkinRoom"
var _tw: Tween

func _physics_process(delta: float) -> void:
	super(delta)
	if !valu:
		return
	if focused:
		_timer += delta * 10
		valu.modulate.a = min((cos(_timer) / 2.5) + 0.6, 1.0)
	else:
		valu.modulate.a = 0.0


func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	
	var test_scene_path = "res://stages/main_menu/objects/skin_test_level.tscn"
	var buffer: PackedScene
	if Scenes._current_scene_buffer && Scenes._current_scene_buffer.resource_path == test_scene_path:
		buffer = Scenes._current_scene_buffer
	else:
		buffer = load(test_scene_path)
	var room = buffer.instantiate()
	
	Data.reset_all_values()
	
	if 0 in Audio._music_channels && is_instance_valid(Audio._music_channels[0]):
		Audio._music_channels[0].process_mode = Node.PROCESS_MODE_DISABLED
	skin_room.get_node("SVC/SV").add_child(room)
	skin_room.visible = true
	if _tw: _tw.kill()
	_tw = skin_room.create_tween().set_parallel().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tw.tween_property(skin_room.get_node("ColorRect"), "modulate:a", 1.0, 0.5).from(0.0)
	_tw.tween_property(skin_room.get_node("Panel"), "modulate:a", 1.0, 0.5).from(0.0)
	_tw.tween_property(skin_room.get_node("Label"), "modulate:a", 1.0, 0.5).from(0.0)
	_tw.tween_property(skin_room.svc, "modulate:a", 1.0, 0.5).from(0.0)
	
	$"..".focused = false
	Scenes.current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	Data.technical_values.main_menu_scene = Scenes.current_scene
	Data.technical_values.temp_f4_key = SettingsManager.get_tweak("f4_keybind", false)
	SettingsManager.set_tweak("f4_keybind", false)
	Scenes.current_scene = room
	Scenes._current_scene_buffer = buffer
	Thunder._connect(Scenes.scene_changed, skin_room._on_scene_changed, CONNECT_DEFERRED)
	Thunder._connect(skin_room.get_node("SVC/SV").child_exiting_tree, skin_room._on_child_exit, CONNECT_ONE_SHOT)

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

func _ready() -> void:
	if valu:
		valu.modulate.a = 0.0
		_template = valu.text
		_update_text()
		SettingsManager.settings_saved.connect(_update_text)
