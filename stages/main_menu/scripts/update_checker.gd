extends Node

#const url: String = "https://mfce.rnx.su/api/version"
#const url_open: String = "https://rnx.su/s/M4WNbNdDw2rAb8Y" # TODO: Change before release
#const url: String = "http://localhost:3000/api/version"

# this is a verification key to ensure we got correct data
const game_key: String = "Mario_Forever_Community_Edition_Update"
# update is checked here
const url: String = \

"https://gist.githubusercontent.com/jue131/97f2819963beea97ed93739fbe57af17/raw/update_check.json"

#"https://gist.githubusercontent.com/jue131/eab20a1ed3661d92106f298ba78aedad/raw/beta_mfce_update_check.json"

# url to open to when an update is available
var url_open: String = "https://gist.github.com/jue131/f7ad31818af19fa91b5175cb67340529"

const COIN = preload("res://sfx/clear.wav")
const MESSAGE_BLOCK = preload("res://engine/objects/bumping_blocks/message_block/message_block.wav")

signal found_update

@export var is_in_main_menu: bool = true

@onready var version: int = ProjectSettings.get_setting("application/thunder_settings/version", 0)
@onready var http_request: HTTPRequest = $"../HTTPRequest"

var update_found: Label
var update_checking: Label
var main_menu_controls: MenuItemsController

var has_update: bool
var checking_tween: Tween

func _ready() -> void:
	if is_in_main_menu:
		main_menu_controls = $"../../Menu/MainMenuControls"
		update_found = $"../UpdateFound"
		update_checking = $"../UpdateChecking"
		
		SettingsManager.show_mouse()
		update_checking.visible = false
		update_found.visible = false
	
		await get_tree().create_timer(0.8, true, false, true).timeout
	elif !Data.technical_values.get("skip_update_check"):
		await get_tree().create_timer(0.3, false, false, true).timeout
		print("[Update Checker] Checking for updates in Save Room...")
		
	if is_in_main_menu:
		update_checking.visible = true
		update_checking.text = "checking for\nupdates..."
		update_checking.modulate.a = 0.75
	elif Data.technical_values.get("skip_update_check"):
		return
	
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
		print("[Update Check Error] Result:", result, " Response Code: ", response_code)
		if is_in_main_menu:
			update_checking.text = "error!\nplease check your internet connection"
		return
	
	if !dict || !dict is Dictionary: return _checking_throw_error()
	print(dict)
	if dict.get("game_name", "") != game_key:
		return _checking_throw_error()
	if !("version" in dict && typeof(dict.version) == TYPE_FLOAT):
		return
	
	if dict.version > version:
		if checking_tween: checking_tween.kill()
		
		has_update = true
		
		if is_in_main_menu:
			update_checking.visible = false
			update_found.visible = true
			var _tw = update_found.create_tween().set_loops().set_trans(Tween.TRANS_SINE)
			_tw.tween_property(update_found, ^"modulate:a", 0.25, 0.5).set_ease(Tween.EASE_IN)
			_tw.tween_property(update_found, ^"modulate:a", 1, 0.5).set_ease(Tween.EASE_OUT)
			
			main_menu_controls.set_meta(&"has_update", true)
			Audio.play_1d_sound(COIN, true, { ignore_pause = true })
		else:
			while is_inside_tree() && get_tree().paused:
				await get_tree().physics_frame
			Scenes.current_scene.get_node("UpdateConfirmModal/Control").toggle()
			var _snd = CharacterManager.get_sound_replace(MESSAGE_BLOCK, MESSAGE_BLOCK, "message_box", false)
			Audio.play_1d_sound(_snd, true, {ignore_pause = true})
			print("[Update Checker] Displaying an update notice!")
		
		if dict.get("open_to", "").begins_with("https://"):
			url_open = dict.open_to
		found_update.emit()
	else:
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


func _checking_throw_error() -> void:
	if !is_in_main_menu: return
	if checking_tween: checking_tween.kill()
	update_checking.modulate.a = 0.9
	update_checking.text = "error!\nplease check for a new version manually. join discord for more information."


func _physics_process(delta: float) -> void:
	if !is_in_main_menu: return
	if !has_update: return
	if !main_menu_controls.focused: return
	
	if Input.is_action_just_pressed("ui_select"):
		OS.shell_open(url_open)
		get_tree().quit()
