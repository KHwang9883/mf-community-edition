extends Node

#const url: String = "https://mfce.rnx.su/api/version"
#const url_open: String = "https://rnx.su/s/M4WNbNdDw2rAb8Y" # TODO: Change before release
#const url: String = "http://localhost:3000/api/version"
const game_key: String = "Mario_Forever_Community_Edition_Update"

const url: String = \

"https://gist.githubusercontent.com/jue131/97f2819963beea97ed93739fbe57af17/raw/update_check.json"

var url_open: String = "https://gist.github.com/jue131/f7ad31818af19fa91b5175cb67340529"

const SELECT_ENTER = preload("res://engine/components/ui/_sounds/select_enter.wav")
const COIN = preload("res://sfx/clear.wav")
@onready var version: int = ProjectSettings.get_setting("application/thunder_settings/version", 0)

@onready var update_found: Label = $"../UpdateFound"
@onready var update_checking: Label = $"../UpdateChecking"
@onready var http_request: HTTPRequest = $"../HTTPRequest"
@onready var main_menu_controls: MenuItemsController = $"../MainMenuControls"

var has_update: bool
var checking_tween: Tween

func _ready() -> void:
	SettingsManager.show_mouse()
	
	await get_tree().create_timer(0.8, true, false, true).timeout
	update_checking.visible = true
	update_checking.text = "checking for\nupdates..."
	checking_tween = update_checking.create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	checking_tween.tween_property(update_checking, ^"modulate:a", 0.25, 0.25).set_ease(Tween.EASE_IN)
	checking_tween.tween_property(update_checking, ^"modulate:a", 0.75, 0.25).set_ease(Tween.EASE_OUT)
	
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
		update_checking.text = "error!\nplease check your internet connection"
		return
	
	if !dict: return _checking_throw_error()
	print(dict)
	if dict.get("game_name", "") != game_key:
		return _checking_throw_error()
	if "version" in dict && typeof(dict.version) == TYPE_FLOAT:
		if dict.version > version:
			if checking_tween: checking_tween.kill()
			update_checking.visible = false
			update_found.visible = true
			var _tw = update_found.create_tween().set_loops().set_trans(Tween.TRANS_SINE)
			_tw.tween_property(update_found, ^"modulate:a", 0.25, 0.5).set_ease(Tween.EASE_IN)
			_tw.tween_property(update_found, ^"modulate:a", 1, 0.5).set_ease(Tween.EASE_OUT)
			
			has_update = true
			if dict.get("open_to", "").begins_with("https://"):
				url_open = dict.open_to
			Audio.play_1d_sound(COIN, true, { ignore_pause = true })
		else:
			if checking_tween: checking_tween.kill()
			update_checking.modulate.a = 0.75
			update_checking.text = "no updates found!"
			get_tree().create_timer(8, true, false, true).timeout.connect(func():
				checking_tween = update_checking.create_tween()
				checking_tween.tween_property(update_checking, "modulate:a", 0.0, 1.0)
			)


func _checking_throw_error() -> void:
	if checking_tween: checking_tween.kill()
	update_checking.modulate.a = 0.9
	update_checking.text = "error!\nplease check for\na new version\nmanually. join discord\nfor more information"


func _physics_process(delta: float) -> void:
	if !has_update: return
	if !main_menu_controls.focused: return
	
	if Input.is_action_just_pressed("ui_select"):
		OS.shell_open(url_open)
		#Audio.play_1d_sound(SELECT_ENTER)
		get_tree().quit()
