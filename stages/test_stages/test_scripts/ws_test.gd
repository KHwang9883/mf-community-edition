extends Control

var ws := WebSocketPeer.new()
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var path_follow_2d_2: PathFollow2D = $Path2D/PathFollow2D2
var has_opened: bool

func _ready() -> void:
	var err = ws.connect_to_url("ws://localhost:16834/livesplit")
	if err:
		print(error_string(err))
		set_process(false)
		return
	ws.poll()
	print(ws.get_ready_state())

func _physics_process(delta: float) -> void:
	path_follow_2d.progress += delta * 100
	path_follow_2d_2.progress += delta * 100

func _process(delta: float) -> void:
	ws.poll()
	var state = ws.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if !has_opened:
			has_opened = true
			print("Connection established")
		while ws.get_available_packet_count():
			print("Packet: ", ws.get_packet().get_string_from_utf8())
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = ws.get_close_code()
		var reason = ws.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false)


func _on_button_pressed() -> void:
	_send_msg("startorsplit")


func _on_button_2_pressed() -> void:
	ws.poll()
	var state = ws.get_ready_state()
	print(state)


func _on_button_3_pressed() -> void:
	_send_msg("ping")


func _on_button_4_pressed() -> void:
	_send_msg("starttimer")


func _on_button_5_pressed() -> void:
	_send_msg("reset")

func _send_msg(text: String) -> void:
	ws.poll()
	var state = ws.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		print("Sending message.")
		ws.send_text(text)


func _on_button_6_pressed() -> void:
	Thunder.autosplitter._send_message("gettimerphase")
