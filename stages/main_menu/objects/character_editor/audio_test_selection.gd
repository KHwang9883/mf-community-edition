extends MenuSelection

@onready var valu = get_node_or_null(^"Value")
#var _timer: float
var sounds_arr: Array
var is_custom: bool
var snd_is_selected: bool = false
var snd_total_ids: int
var snd_next_id: int

func _ready() -> void:
	#if valu: valu.modulate.a = 0.0
	snd_total_ids = sounds_arr.size()
	if snd_total_ids != 0:
		snd_next_id = snd_total_ids - 1
	_update_text()

func _handle_focused(focus: bool) -> void:
	focused = focus
	if !focus && selected_sound: return
	#valu.modulate.a = 1.0
	_update_text()

func _physics_process(delta: float) -> void:
	super(delta)
	
	#if !valu:
	#	return
	#if !focused: valu.modulate.a = 0.0


func _handle_select(mouse_input: bool = false) -> void:
	get_tree().call_group(&"_sounds", &"set_selected_false")
	get_tree().call_group(&"preview_sound", &"queue_free")
	snd_is_selected = true
	if !sounds_arr.is_empty():
		#snd_selected_id = randi_range(0, len(sounds_arr) - 1)
		snd_next_id = wrapi(snd_next_id + 1, 0, len(sounds_arr))
		selected_sound = sounds_arr[snd_next_id]
		
	super(mouse_input)
	if !selected_sound:
		snd_is_selected = false
		return
	_update_text()

func _sound_finished() -> void:
	snd_is_selected = false
	_update_text()

func _update_text() -> void:
	if !snd_is_selected:
		if !is_custom:
			valu.text = "default"
			if !selected_sound:
				valu.text = "none"
			return
		valu.text = "custom, total: %d" % [snd_total_ids]
	else:
		valu.text = "playing %d / %d" % [snd_next_id + 1, max(snd_total_ids, 1)]

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
	

func set_selected_false() -> void:
	var _do_update: bool = snd_is_selected
	snd_is_selected = false
	if _do_update:
		_update_text()
