extends "res://engine/scripts/nodes/effects/blinking_canvas_item.gd"

@onready var http_request = $"../HTTPRequest"
@onready var leaderboard = $"../../../Leaderboard"
@onready var please_type = $".."
@onready var url = leaderboard.url
@onready var starter: Node2D = $"../../../Node2D"
@onready var line_edit = $"../LineEdit"
@onready var loading = $"../Loading"
@onready var switch_map = $"../SwitchMap"
@onready var bg = $"../BG"
@onready var color_rect_2 = $"../ColorRect2"

const SUBMITTED = preload("res://stages/extra/minix/sfx/submitted.wav")

var submitting = false

func _physics_process(delta: float) -> void:
	super(delta)
	
	if submitting:
		loading.visible = true
		visible = false
		line_edit.visible = false
		switch_map.visible = false
		bg.visible = false
		color_rect_2.visible = false
	
	if !please_type.visible: return
	
	if Input.is_action_just_pressed("ui_accept") && !submitting && line_edit.text:
		var data = {
			"score": Data.values.score,
			"godlikes": Data.values.godlikes,
			"time": int(Data.values.lasted),
			"version": 1,
			"map": starter.map_names[starter.map_id],
			"username": line_edit.text,
			"game": "MINIX"
		}
		var headers = ["Content-Type: application/json"]
		http_request.request_completed.connect(_on_http_submit, CONNECT_ONE_SHOT)
		print(JSON.stringify(data))
		http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))
		submitting = true

func _on_http_submit(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print(body.get_string_from_utf8())
	Audio.play_1d_sound(SUBMITTED)
	loading.text = "your score has been submitted!!!"
