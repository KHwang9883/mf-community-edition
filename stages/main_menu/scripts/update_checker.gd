extends Node

const url: String = "https://mfce.rnx.su/api/version"
const url_open: String = "https://rnx.su/s/M4WNbNdDw2rAb8Y" # TODO: Change before release
#const url: String = "http://localhost:3000/api/version"

const SELECT_ENTER = preload("res://engine/components/ui/_sounds/select_enter.wav")
const COIN = preload("res://engine/objects/items/coin/coin.wav")
@onready var version = ProjectSettings.get_setting("application/thunder_settings/version", 0)

@onready var update_found: Label = $"../UpdateFound"
@onready var http_request: HTTPRequest = $"../HTTPRequest"
@onready var main_menu_controls: MenuItemsController = $"../MainMenuControls"

var has_update: bool

func _ready() -> void:
	await get_tree().create_timer(1.0, true, false, true).timeout
	http_request.request_completed.connect(_on_http_get, CONNECT_ONE_SHOT)
	
	http_request.request(url)


func _on_http_get(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var dict: Dictionary = {}
	
	if result == HTTPRequest.RESULT_SUCCESS:
		print(response_code)
		var body_res = body.get_string_from_utf8()
		if body_res:
			dict = JSON.parse_string(body_res)
	else:
		print(response_code)
		return
	
	print(dict)
	if dict && "version" in dict && typeof(dict.version) == TYPE_FLOAT && dict.version > version:
		update_found.visible = true
		has_update = true
		Audio.play_1d_sound(COIN)


func _physics_process(delta: float) -> void:
	if !has_update: return
	if !main_menu_controls.focused: return
	
	if Input.is_action_just_pressed("ui_select"):
		OS.shell_open(url_open)
		Audio.play_1d_sound(SELECT_ENTER)
