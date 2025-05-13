extends Node2D

const RECORD := preload("res://stages/extra/minix/objects/leaderboard_record.tscn")
const POOL_SIZE = 100

#var _record_pool := []
var _index: int

var url: String = "https://mfce.rnx.su/api/records"
var map_load_name = "all maps"

@onready var http_request: HTTPRequest = $HTTPRequest
@onready var control: Control = $SubViewportContainer/SubViewport/Control
@onready var menu_controller: MenuItemsController = $SubViewportContainer/SubViewport/Control/MenuItemsController
@onready var prev_page: Label = menu_controller.get_child(0)
var next_page: Label

@onready var version = ProjectSettings.get_setting("application/thunder_settings/version", 0)
@onready var prev_page_temp: String = prev_page.text
@onready var next_page_temp: String

var is_loading = true
var has_results = false
var page := 1
var total_pages: int = 1
var old = false
var has_error: bool = false

func _ready() -> void:
	for i in POOL_SIZE:
		var record = RECORD.instantiate()
		record.hide()
		menu_controller.add_child(record)
	next_page = menu_controller.get_child(0).duplicate()
	next_page.name = "NextPage"
	next_page.change_page_by = 1
	next_page_temp = "go to the next page (%d of %d)"
	menu_controller.add_child(next_page)

func _load_records() -> void:
	is_loading = true
	has_results = false
	menu_controller.mouse_input = false
	menu_controller.move_selector(0, true)

	if http_request.request_completed.is_connected(_on_http_get_leaderboard):
		return

	#if page == 1:
	for i in menu_controller.get_children():
		i.hide()
	_index = 0

	#await get_tree().physics_frame
	has_error = false
	http_request.request_completed.connect(_on_http_get_leaderboard, CONNECT_ONE_SHOT)

	var params = "?page=%d&limit=%d&sortBy=%s&game=%s&sortType=%s&version=%d" % [page, 100, "score", "MINIX", "desc", version]
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
	var json_out = JSON.parse_string(body)
	var dict := {} 

	if json_out != null && json_out is Dictionary:
		dict = json_out
	else:
		dict.totalPages = 0
		dict.records = {}
	total_pages = dict.totalPages

	#if len(menu_controller.get_children()) == 0:
	if !menu_controller.get_child(1).visible:
		setup_selector = true

	if !dict || len(dict.records) == 0:
		has_results = false
	else:
		has_results = true

	prev_page.visible = page > 1
	next_page.visible = page < total_pages
	prev_page.text = prev_page_temp % [page - 1, total_pages]
	next_page.text = next_page_temp % [page + 1, total_pages]
	
	_add_records_to_menu(dict)
	for i in menu_controller.get_children():
		if !i is NinePatchRect:
			continue
		if len(dict.records) > i.get_index() - 1:
			i.set_record(dict.records[i.get_index() - 1])
		else:
			i.set_empty()
	menu_controller.expanded = null
	menu_controller._update_selectors()
	menu_controller.mouse_input = true
	if setup_selector:
		menu_controller.move_selector(0, true)
		menu_controller.queue_redraw()

func _add_records_to_menu(dict) -> void:
	for i in range(len(dict.records)):
		#var record_item = RECORD.instantiate()
		var record_item = menu_controller.get_child(_index + 1)
		_index = wrapi(_index + 1, 0, POOL_SIZE)
		record_item.show()
		record_item.init_record()
