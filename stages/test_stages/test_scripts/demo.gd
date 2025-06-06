extends Node

const INPUTS = [
	&"m_jump", &"m_attack", &"m_run", &"m_extra",
	&"m_up", &"m_left", &"m_down", &"m_right",
	&"ui_accept", &"ui_cancel", &"ui_select", &"pause_toggle",
	&"ui_up", &"ui_left", &"ui_down", &"ui_right",
	&"a_tab", &"a_delete", &"ui_text_backspace_all_to_left", &"ui_text_backspace_all_to_left"
]

var frame: int
var input_array: PackedInt32Array
var is_recording: bool
var is_playback: bool

func _init() -> void:
	for i in range(20):
		var input = InputEventAction.new()
		input.action = INPUTS[19 - i]
		input.pressed = false
		Input.parse_input_event(input)
	is_recording = false

func _physics_process(delta: float) -> void:
	if get_tree().paused && Console.visible:
		return
	if is_playback:
		if frame >= input_array.size():
			return stop_demo()
		for i in range(20):
			#if input_array[frame] >> i & 1:
				#print(INPUTS[i])
			var input = InputEventAction.new()
			input.action = INPUTS[19 - i]
			input.pressed = input_array[frame] >> i & 1
			Input.parse_input_event(input)
		frame += 1
		
	elif is_recording:
		frame = input_array.size()
		input_array.resize(input_array.size() + 1)
		input_array[frame] = 0
		for i in INPUTS:
			input_array[frame] <<= 1
			input_array[frame] |= int(Input.is_action_pressed(i))
		

func start_demo() -> void:
	is_playback = true
	print("Demo playback started!")

func stop_demo() -> void:
	is_playback = false
	print("Demo playback stopped!")

func record_demo() -> void:
	if is_playback: return
	print("Demo recording started!")
	input_array = []
	is_recording = true

func _input(event: InputEvent) -> void:
	if !event.is_pressed() || event.is_echo(): return
	if event is InputEventKey:
		if event.keycode == KEY_KP_7:
			record_demo()
		if event.keycode == KEY_KP_8:
			save_demo()
		if event.keycode == KEY_KP_9:
			load_demo()

func save_demo(path: String = "user://demo.thdm") -> void:
	if !is_recording:
		return print("But it is not recording.")
	if is_playback:
		return print("Cannot save while on playback.")
	if input_array.is_empty():
		return print("There is nothing here to save")
	#var file = FileAccess.open_compressed(path, FileAccess.WRITE)
	is_recording = false
	input_array.append(0)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_16(input_array.size())
	file.store_16(0)
	file.store_buffer(input_array.to_byte_array())
	file.close()
	input_array = []
	print("Demo saved!")
	
	

func load_demo(path: String = "user://demo.thdm") -> void:
	if is_recording:
		return print("But it is recording!")
	var file = FileAccess.open(path, FileAccess.READ)
	var arrlen = file.get_16()
	file.get_16() # Reserved
	var bytearr = file.get_buffer(arrlen * 4)
	file.close()
	input_array = bytearr.to_int32_array()
	if input_array.is_empty():
		return print("The demo is empty!")
	start_demo()
