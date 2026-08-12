extends Node2D

const RECORD := preload("res://stages/extra/minix/objects/leaderboard_record.tscn")
const POOL_SIZE = 100

var _index: int
var map_load_name = "all maps"

@onready var control: Control = $SubViewportContainer/SubViewport/Control
@onready var menu_controller: MenuItemsController = $SubViewportContainer/SubViewport/Control/MenuItemsController
@onready var prev_page: Label = menu_controller.get_child(0)
var next_page: Label

@onready var version = ProjectSettings.get_setting("application/thunder_settings/version", 0)
@onready var prev_page_temp: String = prev_page.text
@onready var next_page_temp: String
@onready var lb_status: Label = %LBStatus
@onready var lb_status_timer: Timer = lb_status.get_node(^"Timer")
var lb_client

var is_loading: bool
var has_results = false
var page := 1
var total_pages: int = 1
var old = false
var has_error: bool = false
var lb_status_checking: bool = true
var _fetch_pending: bool = false

func _ready() -> void:
	var score_loader = get_node_or_null(^"../../MinixScoreLoader")
	lb_client = score_loader.leaderboard_client if score_loader else null
	for i in POOL_SIZE:
		var record = RECORD.instantiate()
		record.hide()
		menu_controller.add_child(record)
	next_page = menu_controller.get_child(0).duplicate()
	next_page.name = "NextPage"
	next_page.change_page_by = 1
	next_page_temp = "go to the next page (%d of %d)"
	menu_controller.add_child(next_page)

	if lb_client:
		lb_client.version = version
		lb_client.game = "MINIX"
		lb_client.online_checked.connect(_on_online_checked)
		lb_client.records_loaded.connect(_on_records_loaded)
	else:
		_on_online_checked(false)

	await get_tree().create_timer(0.8, true, false, true).timeout
	if !is_inside_tree(): return
	Thunder._connect(lb_status_timer.timeout, func():
		if !lb_status_checking:
			lb_status_timer.stop()
			return
		lb_status.visible_characters = wrapi(
			lb_status.visible_characters + 1, len(lb_status.text) - 3, len(lb_status.text) + 1
		)
	)
	if lb_client:
		lb_client.check_online()


func _on_online_checked(online: bool) -> void:
	lb_status_checking = false
	lb_status.visible_ratio = 1.0
	if online:
		lb_status.text = "online"
		lb_status.add_theme_color_override(&"font_color", Color.html("c0f8c0"))
	else:
		lb_status.text = "offline"
		lb_status.add_theme_color_override(&"font_color", Color.html("f0cdc2"))


func _load_records() -> void:
	_fetch_pending = true
	is_loading = true
	has_results = false
	menu_controller.mouse_input = false
	menu_controller.move_selector(0, true)

	for i in menu_controller.get_children():
		i.hide()
	_index = 0

	has_error = false
	if lb_client:
		lb_client.fetch_records(page, 100, map_load_name)
	else:
		has_error = true


func _on_records_loaded(ok: bool, response_code: int, payload: Dictionary) -> void:
	_fetch_pending = false
	is_loading = false

	if response_code == 401:
		old = true
	if response_code not in [401, 200]:
		has_error = true
		print("leaderboard fetch error: ", response_code, " ok=", ok)
	else:
		has_error = false

	setup_records(payload)


func setup_records(dict: Dictionary) -> void:
	var setup_selector = false

	if dict == null || dict.is_empty():
		dict = {"totalPages": 0, "records": []}
	if !"totalPages" in dict:
		dict.totalPages = 0
	if !"records" in dict || dict.records == null:
		dict.records = []

	total_pages = int(dict.totalPages)

	if !menu_controller.get_child(1).visible:
		setup_selector = true

	var records = dict.records
	if typeof(records) != TYPE_ARRAY:
		records = []
	if len(records) == 0:
		has_results = false
	else:
		has_results = true

	prev_page.visible = page > 1
	next_page.visible = page < total_pages
	prev_page.text = prev_page_temp % [page - 1, total_pages]
	next_page.text = next_page_temp % [page + 1, total_pages]

	_add_records_to_menu(records)
	for i in menu_controller.get_children():
		if !i is NinePatchRect:
			continue
		if len(records) > i.get_index() - 1:
			i.set_record(records[i.get_index() - 1])
		else:
			i.set_empty()
	menu_controller.expanded = null
	menu_controller._update_selectors()
	menu_controller.mouse_input = true
	if setup_selector:
		menu_controller.move_selector(0, true)
		menu_controller.queue_redraw()


func _add_records_to_menu(records) -> void:
	for i in range(len(records)):
		var record_item = menu_controller.get_child(_index + 1)
		_index = wrapi(_index + 1, 0, POOL_SIZE)
		record_item.show()
		record_item.init_record()
