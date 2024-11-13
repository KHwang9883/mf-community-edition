extends Label

signal activated
signal deactivated

var string = "kevin"
var progress = 0

@onready var music_loader = $"../../MusicLoader"
@onready var node_2d = $"../Node2D"
#@onready var music_overlay = $"../../MusicOverlay"
@onready var node_2d_2 = $"../Node2D2"

const SECRET_CODE_TYPE = preload("res://sfx/secret_code_type.ogg")
const KEVIN_ACTIVATED = preload("res://sfx/kevin_activated.ogg")

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
	
	if progress < len(string) && !KevinGlobal.activated && !is_pressed:
		if Input.is_key_pressed(OS.find_keycode_from_string(string[progress])):
			is_pressed = true
			progress += 1
			print(progress)
			if progress < len(string):
				Audio.play_1d_sound(SECRET_CODE_TYPE)
			else:
				Audio.play_1d_sound(KEVIN_ACTIVATED)
				KevinGlobal.activated = true
				activated.emit()
				Thunder._current_camera.shock(0.5, Vector2(0.4, 0.4))
		elif Input.is_anything_pressed():
			is_pressed = true
			progress = 0
			text = ""
	
	if KevinGlobal.activated && music_loader.index == 0:
		music_loader.index = 1
		node_2d.visible = true
		node_2d_2.visible = true
		#music_overlay.displaying_mode = music_overlay.DisplayingMode.TYPER
		#music_overlay.play(1)
	
	if KevinGlobal.activated:
		modulate.a -= 2 * _delta
		# Reset Kevin mode
		if Input.is_key_pressed(KEY_BACKSPACE):
			kevin_reset()
			deactivated.emit()


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
	progress = 0
