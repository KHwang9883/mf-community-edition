extends MenuSelection

const Choicers = ["smb", "squario"]

@onready var squario_mus: int = SettingsManager.get_tweak("squario_music", 1)
@onready var music_loader: Node = $"../../../MusicLoader"
@onready var controls: MenuItemsController = $".."
@onready var start_5: Label = $"."
@onready var init_text: String = start_5.text
var squario_lvl_complete

func _ready() -> void:
	update_music()


func update_music() -> void:
	if squario_mus == 1:
		music_loader.index = 1
		music_loader.play_buffered()
		start_5.text = init_text % Choicers[1]
		if !SecretsManager.has_meta(&"squario_lvl_complete"):
			squario_lvl_complete = load("res://music/extra/squario/levelcomplete.mp3")
			SecretsManager.set_meta(&"squario_lvl_complete", squario_lvl_complete)
	else:
		music_loader.index = 0
		music_loader.play_buffered()
		start_5.text = init_text % Choicers[0]
	

func _physics_process(delta: float) -> void:
	super(delta)
	if focused && controls.focused:
		if Input.is_action_just_pressed(&"ui_left") || Input.is_action_just_pressed(&"ui_right"):
			_play_sound()
			toggle()


func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	toggle()


func toggle() -> void:
	if squario_mus == 1:
		SettingsManager.set_tweak("squario_music", 0)
		squario_mus = 0
	else:
		SettingsManager.set_tweak("squario_music", 1)
		squario_mus = 1
	update_music()
	SettingsManager.save_tweaks()
