extends MenuSelection

@onready var valu = get_node_or_null(^"Value")
#var _timer: float
var sounds_arr: Array
var snd_selected_id: int = -1
var snd_total_ids: int

func _ready() -> void:
	if valu: valu.modulate.a = 0.0
	snd_total_ids = sounds_arr.size()

func _handle_focused(focus: bool) -> void:
	focused = focus
	if !focus: return
	valu.modulate.a = 1.0
	_update_text()

func _physics_process(delta: float) -> void:
	super(delta)
	
	if !valu:
		return
	if !focused: valu.modulate.a = 0.0


func _handle_select(mouse_input: bool = false) -> void:
	get_tree().set_group(&"_sounds", "snd_selected_id", -1)
	get_tree().call_group(&"preview_sound", &"queue_free")
	snd_selected_id = 0
	if !sounds_arr.is_empty():
		snd_selected_id = randi_range(0, len(sounds_arr) - 1)
		selected_sound = sounds_arr[snd_selected_id]
		
	super(mouse_input)
	if !selected_sound:
		snd_selected_id = -1
		return
	_update_text()

func _sound_finished() -> void:
	snd_selected_id = -1
	_update_text()

func _update_text() -> void:
	if snd_selected_id == -1:
		if sounds_arr.is_empty():
			valu.text = "default"
			if !selected_sound:
				valu.text = "none"
			return
		valu.text = "total: %d" % [snd_total_ids]
	else:
		valu.text = "playing %d / %d" % [snd_selected_id + 1, max(snd_total_ids, 1)]

func _play_sound():
	if !selected_sound:
		valu.text = "empty sound!"
		return
	var snd: AudioStreamPlayer = Audio._create_1d_player(false, false)
	snd.add_to_group(&"preview_sound")
	snd.finished.connect(_sound_finished)
	snd.bus = "1D Sound"
	snd.stream = selected_sound
	snd.process_mode = Node.PROCESS_MODE_ALWAYS
	snd.play.call_deferred()
	
