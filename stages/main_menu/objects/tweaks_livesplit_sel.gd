extends MenuSelection

#@onready var valu = get_node_or_null(^"Value")
#var _timer: float

@onready var window: Window = $Window
@onready var _split_on = %split_on
@onready var _start_on = %start_on
@onready var _reset_on = %reset_on
@onready var config = Thunder.autosplitter.config.duplicate(true)

#func _physics_process(delta: float) -> void:
	#super(delta)
	#if !valu:
		#return
	#if focused:
		#_timer += delta * 10
		#valu.modulate.a = min((cos(_timer) / 2.5) + 0.6, 1.0)
	#else:
		#valu.modulate.a = 0.0

func _ready() -> void:
	update_checkboxes()

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	
	window.show()

func update_checkboxes() -> void:
	%cb_enabled.button_pressed = bool(config.get("enabled", false))
	%cb_pause_load.button_pressed = bool(config.get("pause_on_loading", true))
	%cb_restart.button_pressed = bool(config.get("restart_hotkey", false))
	for i in _split_on.get_children():
		if !i is CheckBox: continue
		i.button_pressed = config.split_on.has(i.name)
	for i in _start_on.get_children():
		if !i is CheckBox: continue
		i.button_pressed = config.start_on.has(i.name)
	for i in _reset_on.get_children():
		if !i is CheckBox: continue
		i.button_pressed = config.reset_on.has(i.name)

func save_checkboxes() -> void:
	config.enabled = %cb_enabled.button_pressed
	config.pause_on_loading = %cb_pause_load.button_pressed
	config.restart_hotkey = %cb_restart.button_pressed
	config.split_on = []
	for i in _split_on.get_children():
		if !i is CheckBox: continue
		if i.button_pressed:
			config.split_on.append(i.name)
	config.start_on = []
	for i in _start_on.get_children():
		if !i is CheckBox: continue
		if i.button_pressed:
			config.start_on.append(i.name)
	config.reset_on = []
	for i in _reset_on.get_children():
		if !i is CheckBox: continue
		if i.button_pressed:
			config.reset_on.append(i.name)

func _on_window_close_requested() -> void:
	config = Thunder.autosplitter.config.duplicate(true)
	update_checkboxes()
	window.hide()


func _on_apply_btn_pressed() -> void:
	save_checkboxes()
	Thunder.autosplitter.config = config
	Thunder.autosplitter.save_config()
	window.hide()
	if config.enabled:
		_on_reconnect_pressed()


func _on_reconnect_pressed() -> void:
	Thunder.autosplitter.ws.poll()
	var state = Thunder.autosplitter.ws.get_ready_state()
	if state != WebSocketPeer.STATE_OPEN:
		Thunder.autosplitter.has_closed = false
		Thunder.autosplitter.has_connected = false
		var err = Thunder.autosplitter.connect_websocket()
		if err: print(err)
