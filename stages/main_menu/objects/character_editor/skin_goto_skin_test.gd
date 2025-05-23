extends MenuSelection

@onready var valu = get_node_or_null(^"Value")
var _timer: float
@onready var skin_room: CanvasLayer = $"../../SkinRoom"

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
	
	Audio._music_channels[0].process_mode = Node.PROCESS_MODE_DISABLED
	skin_room.get_node("SVC/SV").add_child(room)
	skin_room.visible = true
	
	$"..".focused = false
	Scenes.current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	Data.technical_values.main_menu_scene = Scenes.current_scene
	Data.technical_values.temp_f4_key = SettingsManager.get_tweak("f4_keybind", false)
	SettingsManager.set_tweak("f4_keybind", false)
	Scenes.current_scene = room
	Scenes._current_scene_buffer = buffer
	Thunder._connect(Scenes.scene_changed, skin_room._on_scene_changed, CONNECT_DEFERRED)
	Thunder._connect(skin_room.get_node("SVC/SV").child_exiting_tree, skin_room._on_child_exit, CONNECT_ONE_SHOT)
