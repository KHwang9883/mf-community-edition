extends Node

const KONAMI = preload("res://sfx/konami.ogg")

const ACTIONS: PackedStringArray = [
	"m_up", "m_up", "m_down", "m_down", "m_left", "m_right", "m_left", "m_right", "m_run", "m_jump", "ui_accept"
]

var progress: int = 0
var next_action: String
var activated: bool

func _input(event: InputEvent) -> void:
	if activated: return
	if !event.is_pressed() || event.is_echo(): return
	
	if event is InputEventKey:
		if next_action && event.is_action_pressed(next_action):
			progress += 1
			#print(progress)
		else:
			progress = 0
			#print("RESET")
	elif event is InputEventJoypadButton:
		progress = 0
		#print("RESET")
	
	if progress == len(ACTIONS):
		Audio.play_1d_sound(KONAMI)
		SecretsManager.set_secret("story mode completed", true)
		activated = true
		return
	next_action = ACTIONS[progress]
	#print(next_action)
