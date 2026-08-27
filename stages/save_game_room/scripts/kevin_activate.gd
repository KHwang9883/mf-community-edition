extends Label

signal activated
signal dumbactivated
signal deactivated

var string = "kevin"
var dumbstring = "myname"
var progress = 0
var dumbprogress = 0
var dumb_activated: bool

@onready var music_loader = $"../../MusicLoader"
@onready var node_2d = $"../Node2D"
#@onready var music_overlay = $"../../MusicOverlay"
@onready var node_2d_2 = $"../Node2D2"
@onready var kevin_control: Control = $"../../CanvasLayer2/KevinControl"
@onready var kevin_label_fake: Label = $"../KevinLabelFake"

const SECRET_CODE_TYPE = preload("res://sfx/secret_code_type.ogg")
const KEVIN_ACTIVATED = preload("res://sfx/kevin_activated.ogg")
const EVENT_WIN_LEVEL_ORIGINAL = preload("res://sfx/event_win_level_original.ogg")

var only_compat_activation: bool
var _held_keys: Dictionary = {}

func _ready() -> void:
	node_2d.visible = false
	node_2d_2.visible = false

func _physics_process(_delta: float) -> void:
	text = ""
	var player: Player = Thunder._current_player
	if !player: return
	if player.warp != player.Warp.NONE: return
	if player.no_movement: return
	if !SecretsManager.is_endgame(): return
	
	for i in range(progress):
		text += string[i]
	
	if KevinGlobal.activated && music_loader.index == 0:
		music_loader.index = 1
		node_2d.visible = true
		node_2d_2.visible = true
		if !SecretsManager.has_secret("hint_guy_encountered"):
			kevin_control.toggle()
		SecretsManager.set_secret("hint_guy_encountered", true, true, false)
		#music_overlay.displaying_mode = music_overlay.DisplayingMode.TYPER
		#music_overlay.play(1)
	
	if KevinGlobal.activated:
		modulate.a -= 2 * _delta
		# Reset Kevin mode
		if Input.is_key_pressed(KEY_BACKSPACE):
			kevin_reset()
			deactivated.emit()

func _is_modifier_key(keycode: Key) -> bool:
	return keycode == KEY_SHIFT || keycode == KEY_CTRL || keycode == KEY_ALT || keycode == KEY_META

func _has_other_keys_pressed(except_keycode: Key) -> bool:
	for key in _held_keys:
		if key == except_keycode:
			continue
		if Input.is_key_pressed(key):
			return true
	return false

func _input(event: InputEvent) -> void:
	if event is InputEventKey && !event.is_echo() && !_is_modifier_key(event.keycode):
		if event.pressed:
			_held_keys[event.keycode] = true
		else:
			_held_keys.erase(event.keycode)
	
	if KevinGlobal.activated: return
	if !(event is InputEventKey && event.is_pressed() && !event.is_echo()):
		return
	# Held modifiers shouldn't count as a new (wrong) key.
	if _is_modifier_key(event.keycode):
		return
	var player: Player = Thunder._current_player
	if !player: return
	if player.warp != player.Warp.NONE: return
	if player.no_movement: return
	if !SecretsManager.is_endgame(): return
	
	if !only_compat_activation:
		if progress_process(event.keycode, true):
			return
	if !SecretsManager.has_secret("hint_guy_encountered"):
		progress_process(event.keycode, false)

func progress_process(keycode: Key, real: bool) -> bool:
	var _progress: int = progress if real else dumbprogress
	var _string: String = string if real else dumbstring
	if _progress >= len(_string): return false
	if keycode == OS.find_keycode_from_string(_string[_progress]):
		if _progress == 0 && _has_other_keys_pressed(keycode):
			return false
		if real:
			progress += 1
			dumbprogress = 0
			kevin_label_fake.visible = false
		else:
			dumbprogress += 1
			progress = 0
		#print(progress)
		if real:
			if progress < len(_string):
				Audio.play_1d_sound(SECRET_CODE_TYPE, true, { ignore_pause = true })
			else:
				kevin_activate()
		elif !dumb_activated && dumbprogress >= len(_string):
			Audio.play_1d_sound(EVENT_WIN_LEVEL_ORIGINAL, true, { ignore_pause = true, volume = -4 })
			dumbactivated.emit()
			kevin_label_fake.text = "uh, no... not literally, you dummy"
			kevin_label_fake.visible = true
			dumb_activated = true
			var _twe = kevin_label_fake.create_tween()
			_twe.tween_interval(5.0)
			_twe.tween_property(kevin_label_fake, "modulate:a", 0.0, 0.7)
		return true
	if real:
		progress = 0
	else:
		dumbprogress = 0
		kevin_label_fake.visible = false
	text = ""
	return false

func kevin_reset(no_music: bool = false) -> void:
	if !no_music:
		music_loader.index = 0
	node_2d.visible = false
	node_2d_2.visible = false
	#music_overlay.music_text.visible_ratio = 1
	#music_overlay.music_text.modulate.a = 1
	#music_overlay.displaying_mode = music_overlay.DisplayingMode.ROLL_IN_OUT
	#music_overlay.play(0)
	KevinGlobal.activated = false
	modulate.a = 1
	text = ""
	kevin_label_fake.visible = false
	progress = 0

func kevin_activate() -> void:
	Audio.play_1d_sound(KEVIN_ACTIVATED, true, { ignore_pause = true })
	KevinGlobal.activated = true
	activated.emit()
	Thunder._current_camera.shock(0.5, Vector2(1, 1))

func set_compat_activation_only() -> void:
	only_compat_activation = true
