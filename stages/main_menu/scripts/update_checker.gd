extends Node

const url: String = "https://mfce.rnx.su"
const url_backup: String = "https://mfce.nx.wtf"
#const url: String = "http://127.0.0.1:3000/api/version/v2"

# this is a verification key to ensure we got correct data
const game_key: String = "MFCE"

# url to open to when an update is available
var url_open: String

#const WHY_TO_UPDATE: String = "it is extremely recommended to update,
#as it includes bug fixes, compatibility with
#mario minix leaderboards, and possibly new content.
#
#older versions of the game are not supported, but you can
#continue for now and update later."

const COIN = preload("res://sfx/clear.wav")
const MESSAGE_BLOCK = preload("res://engine/objects/bumping_blocks/message_block/message_block.wav")
const api_str: String = "/api/version/v2"

signal found_update

@export var is_in_main_menu: bool = true

@onready var version: int = ProjectSettings.get_setting("application/thunder_settings/version", 0)
@onready var http_request: HTTPRequest = $"../HTTPRequest"

var update_found: RichTextLabel
var update_checking: Label
var main_menu_controls: MenuItemsController

var has_update: bool
var checking_tween: Tween
var backup: int = 0

func _ready() -> void:
	
	if is_in_main_menu:
		main_menu_controls = $"../../Menu/MainMenuControls"
		update_found = $"../UpdateFound"
		update_checking = $"../UpdateChecking"
		
		SettingsManager.show_mouse()
		update_checking.visible = false
		update_found.visible = false
	
		await get_tree().create_timer(0.8, true, false, true).timeout
	
	if Data.technical_values.get("update_delayer"):
		return
	
	if !is_in_main_menu && !Data.technical_values.get("skip_update_check"):
		await get_tree().create_timer(0.3, false, false, true).timeout
		print("[Update Checker] Checking for updates in Save Room...")
		
	if is_in_main_menu:
		update_checking.visible = true
		update_checking.text = "checking for\nupdates..."
		update_checking.modulate.a = 0.75
	elif Data.technical_values.get("skip_update_check"):
		return
	
	http_request.request_completed.connect(_on_http_get, CONNECT_ONE_SHOT)
	http_request.request(url + api_str + "?gameName=" + game_key + "&version=" + str(version))


func _on_http_get(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var dict: Dictionary = {}
	
	if response_code == 204:
		_checking_not_found()
		return
	
	if result == HTTPRequest.RESULT_SUCCESS:
		print(response_code)
		var body_res = JSON.parse_string(body.get_string_from_utf8())
		if body_res:
			dict = body_res
	else:
		print("[Update Check Error] Result: ", _get_result_text(result), " Response Code: ", response_code)
		if backup == 0:
			_checking_throw_error(true)
			return
		if is_in_main_menu:
			update_checking.text = "error!\nplease check your internet connection"
		return
	
	if !dict || !dict is Dictionary:
		return _checking_throw_error()
	print(dict)
	if dict.get("gameName", "") != game_key:
		return _checking_throw_error()
	if !("version" in dict && typeof(dict.version) == TYPE_FLOAT):
		return _checking_throw_error()
	
	if checking_tween: checking_tween.kill()
	
	has_update = true
	var version_text: String = dict.get("versionPretty", "")
	var why_to_update: String = dict.get("whyToUpdate", "")
	
	if is_in_main_menu:
		update_checking.visible = false
		update_found.visible = true
		
		var _tw = update_found.create_tween().set_loops().set_trans(Tween.TRANS_SINE)
		_tw.tween_property(update_found, ^"modulate:a", 0.4, 0.3)
		_tw.tween_property(update_found, ^"modulate:a", 1, 0.3)
		
		var _template = update_found.text.format([version_text])
		var _events: Array[InputEvent] = InputMap.action_get_events(&"ui_select")
		var _event: String = "space"
		var _temp: String
		for i in _events:
			if i is InputEventKey:
				_temp = i.as_text().get_slice(' (', 0) + ' button'
				#if SettingsManager.device_keyboard:
				_event = _temp
				break
			if _temp: _event = _temp
		
		update_found.text = _template % [_event]
		
		main_menu_controls.set_meta(&"has_update", true)
		Audio.play_1d_sound(COIN, true, { ignore_pause = true })
	else:
		while is_inside_tree() && get_tree().paused:
			await get_tree().physics_frame
		Scenes.current_scene.get_node("UpdateConfirmModal/Control").toggle()
		
		var _snd = CharacterManager.get_sound_replace(MESSAGE_BLOCK, MESSAGE_BLOCK, "message_box", false)
		Audio.play_1d_sound(_snd, true, {ignore_pause = true})
		print("[Update Checker] Displaying an update notice!")
	
	
	var _lb_upd: Label = Scenes.current_scene.get_node("UpdateConfirmModal/Control/LabelUpdate")
	_lb_upd.text = _lb_upd.text.format([
		("(" + version_text + ") " if version_text else ""),
		why_to_update
	])
	
	url_open = dict.get("openTo", "")
	found_update.emit()


func _checking_throw_error(soft: bool = false) -> void:
	if backup == 0:
		backup = 1
		http_request.request_completed.connect(_on_http_get, CONNECT_ONE_SHOT)
		http_request.request(url_backup + api_str + "?gameName=" + game_key + "&version=" + str(version))
		return
	if soft: return
	if !is_in_main_menu: return
	if checking_tween: checking_tween.kill()
	update_checking.modulate.a = 0.9
	update_checking.text = "error!\nplease check for a new version manually. join discord for more information."


func _checking_not_found() -> void:
	var tw = Data.create_tween().set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_interval(180.0)
	tw.tween_callback(func(): Data.technical_values.update_delayer = false)
	Data.technical_values.update_delayer = true
	
	if !is_in_main_menu:
		Data.technical_values.skip_update_check = true
		
		print("[Update Checker] No updates found")
		return
	if checking_tween: checking_tween.kill()
	update_checking.modulate.a = 0.75
	update_checking.text = ""
	get_tree().create_timer(8, true, false, true).timeout.connect(func():
		checking_tween = update_checking.create_tween()
		checking_tween.tween_property(update_checking, "modulate:a", 0.0, 1.0)
	)


func _physics_process(delta: float) -> void:
	if !is_in_main_menu: return
	if !has_update: return
	if !main_menu_controls.focused: return
	
	if Input.is_action_just_pressed("ui_select"):
		OS.shell_open(url_open)
		get_tree().quit()


static func _get_result_text(result: HTTPRequest.Result) -> String:
	match result:
		HTTPRequest.RESULT_SUCCESS:
			return "Success"
		HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH:
			return "CHUNKED_BODY_SIZE_MISMATCH"
		HTTPRequest.RESULT_CANT_CONNECT:
			return "CANT_CONNECT"
		HTTPRequest.RESULT_CANT_RESOLVE:
			return "CANT_RESOLVE"
		HTTPRequest.RESULT_CONNECTION_ERROR:
			return "CONNECTION_ERROR"
		HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
			return "TLS_HANDSHAKE_ERROR"
		HTTPRequest.RESULT_NO_RESPONSE:
			return "NO_RESPONSE"
		HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED:
			return "BODY_SIZE_LIMIT_EXCEEDED"
		HTTPRequest.RESULT_BODY_DECOMPRESS_FAILED:
			return "BODY_DECOMPRESS_FAILED"
		HTTPRequest.RESULT_REQUEST_FAILED:
			return "REQUEST_FAILED"
		HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN:
			return "RESULT_DOWNLOAD_FILE_CANT_OPEN"
		HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR:
			return "DOWNLOAD_FILE_WRITE_ERROR"
		HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:
			return "REDIRECT_LIMIT_REACHED"
		HTTPRequest.RESULT_TIMEOUT:
			return "Timeout"
	return "Unknown"
