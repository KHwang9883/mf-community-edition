extends MenuSelection

var is_enabled: bool = true

@onready var please_type: Node2D = $"../../PleaseType"
@onready var input_box: Node2D = $"../../PleaseType/InputBox"
@onready var line_edit: LineEdit = $"../../PleaseType/InputBox/LineEdit"
@onready var enter_to_preview: Label = $"../../PleaseType/EnterToPreview"

@onready var leaderboard: Node2D = $"../../../Leaderboard"
@onready var http_request: HTTPRequest = $"../../PleaseType/HTTPRequest"
@onready var url = leaderboard.url
@onready var loading: Label = $"../../PleaseType/Submitting/Loading"
@onready var congrats: Label = $"../../PleaseType/Submitting/congrats"
@onready var submitting_box: Node2D = $"../../PleaseType/Submitting"

@onready var minix_controls: MenuItemsController = $".."
@onready var starter: Node2D = $"../../../Node2D"

const SUBMITTED = preload("res://stages/extra/minix/sfx/submitted.wav")

var submitting = false

func _handle_select() -> void:
	if !is_enabled:
		if congrats.visible && please_type.visible:
			Audio.play_1d_sound(selected_sound)
			please_type.visible = false
			return
		Audio.play_1d_sound(preload("res://stages/extra/minix/status/minix_coin_time.wav"))
		return
	super()
	minix_controls.focused = false
	please_type.visible = true
	submitting_box.visible = false
	line_edit.grab_focus()
	line_edit.focus_exited.connect(_on_line_edit_focus_exited, CONNECT_ONE_SHOT)

func _physics_process(delta: float) -> void:
	super(delta)
	if !focused: return
	
	if submitting:
		submitting_box.visible = true
		input_box.visible = false
		return
	
	if !please_type.visible: return
	
	if Input.is_action_just_pressed("ui_cancel") || (submitting && Input.is_action_just_pressed("ui_accept")):
		_on_line_edit_focus_exited()
		Thunder._disconnect(line_edit.focus_exited, _on_line_edit_focus_exited)
		
	var can_submit: bool = false
	var regex = RegEx.new()
	regex.compile("[^A-Za-z0-9\\ _\\-.]")
	if len(line_edit.text) > 2 && !regex.search(line_edit.text):
		can_submit = true
	
	enter_to_preview.visible = can_submit
	
	if !is_enabled: return
	
	if can_submit && !submitting && Input.is_action_just_pressed("ui_accept"):
		Audio.play_1d_sound(selected_sound)
		Thunder._disconnect(line_edit.focus_exited, _on_line_edit_focus_exited)
		line_edit.release_focus()
		
		var data = {
			"score": Data.values.score,
			"godlikes": Data.values.godlikes,
			"time": int(Data.values.lasted),
			"version": 2, # GAME VERSION
			"map": starter.map_names[starter.map_id],
			"username": line_edit.text,
			"game": "MINIX"
		}
		var headers = ["Content-Type: application/json"]
		http_request.request_completed.connect(_on_http_submit, CONNECT_ONE_SHOT)
		print(JSON.stringify(data))
		http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))
		submitting = true
		is_enabled = false

func _on_http_submit(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print(body.get_string_from_utf8())
	submitting = false
	
	if response_code != 201:
		loading.text = "error"
		return
	
	Audio.play_1d_sound(SUBMITTED)
	
	congrats.visible = true
	loading.visible = false


func _on_line_edit_focus_exited() -> void:
	minix_controls.focused = true
	please_type.visible = false
