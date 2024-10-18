extends Node2D

var url: String = "https://mfce.rnx.su/api/records"
var map_load_name = "all maps"

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var control: Control = $SubViewportContainer/SubViewport/Control
@onready var menu_controller: MenuItemsController = $SubViewportContainer/SubViewport/Control/MenuItemsController
@onready var version = ProjectSettings.get_setting("application/thunder_settings/version", 0)

var is_loading = true
var has_results = false
var page = 1
var old = false
var has_error: bool = false

func _load_records() -> void:
	is_loading = true
	has_results = false

	if http_request.request_completed.is_connected(_on_http_get_leaderboard):
		return

	if page == 1:
		for i in menu_controller.get_children():
			i.queue_free()

	#await get_tree().physics_frame
	has_error = false
	http_request.request_completed.connect(_on_http_get_leaderboard, CONNECT_ONE_SHOT)

	var params = "?page=%d&limit=%d&sortBy=%s&game=%s&sortType=%s&version=%d" % [page, 1000, "score", "MINIX", "desc", version]
	print(map_load_name)
	if map_load_name != "all maps":
		params += "&map=" + map_load_name.uri_encode()

	var error = http_request.request(url + params)
	if error: print("ERROR:", error)


func _on_http_get_leaderboard(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS:
		var body_res = body.get_string_from_utf8()
		setup_records(body_res)
	else:
		print(response_code)
	print(result)
	is_loading = false

	if response_code == 401:
		old = true
	if !response_code in [401, 200]:
		has_error = true


func setup_records(body: String) -> void:
	var setup_selector = false
	var dict = JSON.parse_string(body)

	if dict == null:
		dict.records = {}

	if len(menu_controller.get_children()) == 0:
		setup_selector = true

	if len(dict.records) == 0:
		has_results = false
	else:
		has_results = true

	for i in range(len(dict.records)):
		var record_item = preload("res://stages/extra/minix/objects/leaderboard_record.tscn").instantiate()
		menu_controller.add_child(record_item)
	for i in menu_controller.get_children():
		if !i is NinePatchRect:
			continue
		if len(dict.records) > i.get_index():
			i.set_record(dict.records[i.get_index()])
		else:
			i.set_empty()
	menu_controller._update_selectors()
	if setup_selector:
		menu_controller.move_selector(0, true)
