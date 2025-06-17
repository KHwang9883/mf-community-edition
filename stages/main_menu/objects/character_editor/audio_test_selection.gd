extends MenuSelection

@onready var valu = get_node_or_null(^"Value")
var _timer: float
var sounds_arr: Array

func _ready() -> void:
	if valu: valu.modulate.a = 0.0

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
	for i in Audio.get_children():
		if i is AudioStreamPlayer && !i in Audio._music_channels:
			i.stop()
			i.queue_free()
	if !sounds_arr.is_empty():
		selected_sound = sounds_arr[randi_range(0, len(sounds_arr) - 1)]
	super(mouse_input)
