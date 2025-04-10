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

var is_pressed: bool

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
	
	if !Input.is_anything_pressed():
		is_pressed = false
	
	progress_process(progress, string, true)
	if !SecretsManager.has_secret("hint_guy_encountered"):
		progress_process(dumbprogress, dumbstring, false)
	
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

func progress_process(_progress: int, _string: String, real: bool) -> void:
	if _progress < len(_string) && !KevinGlobal.activated && !is_pressed:
		if Input.is_key_pressed(OS.find_keycode_from_string(_string[_progress])):
			is_pressed = true
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
					Audio.play_1d_sound(KEVIN_ACTIVATED, true, { ignore_pause = true })
					KevinGlobal.activated = true
					activated.emit()
					Thunder._current_camera.shock(0.5, Vector2(1, 1))
			elif !dumb_activated && dumbprogress >= len(_string):
					Audio.play_1d_sound(EVENT_WIN_LEVEL_ORIGINAL, true, { ignore_pause = true, volume = -4 })
					dumbactivated.emit()
					kevin_label_fake.text = "uh, no... not literally, you dummy"
					kevin_label_fake.visible = true
					dumb_activated = true
					var _twe = kevin_label_fake.create_tween()
					_twe.tween_interval(5.0)
					_twe.tween_property(kevin_label_fake, "modulate:a", 0.0, 0.7)
		elif Input.is_anything_pressed():
			if real:
				progress = 0
			else:
				dumbprogress = 0
				is_pressed = true
				kevin_label_fake.visible = false
			text = ""

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
