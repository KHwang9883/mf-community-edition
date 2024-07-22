extends Node2D

var url: String = "http://localhost:3000/api/records"

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var control: Control = $SubViewportContainer/SubViewport/Control
@onready var menu_controller: MenuItemsController = $SubViewportContainer/SubViewport/Control/MenuItemsController

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	print("ALLO")
	http_request.request_completed.connect(_on_http_get_leaderboard)
	var params = "?page=%d&limit=%d&sortBy=%s&game=%s&sortType=%s" % [1, 10, "score", "MINIX", "desc"]
	
	var error = http_request.request(url + params)
	if error: print(error)


func _on_http_get_leaderboard(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS:
		print(body.get_string_from_utf8())
		setup_records(body.get_string_from_utf8())
	else:
		print(response_code)
	print(result)


func setup_records(body: String) -> void:
	var dict = JSON.parse_string(body)
	if dict == null:
		dict.records = {}
	for i in menu_controller.get_children():
		if !i is NinePatchRect:
			continue
		if len(dict.records) > i.get_index():
			print(len(dict.records))
			i.set_record(dict.records[i.get_index()])
		else:
			i.set_empty()
