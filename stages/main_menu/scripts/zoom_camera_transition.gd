extends Camera2D

signal menu_initiated

@onready var music_loader: Node = $"../Menu/MusicLoader"
@onready var main_menu_controls: MenuItemsController = $"../Menu/MainMenuControls"

const FADEOUT = preload("res://engine/components/ui/_sounds/fadeout.wav")

func _ready() -> void:
	if Data.technical_values.get("_skip_menu_transition", false):
		Data.technical_values.erase("_skip_menu_transition")
		await get_tree().physics_frame
		music_loader.play_buffered()
		main_menu_controls.focused = true
		menu_initiated.emit()
		return
	
	var _sfx = CharacterManager.get_sound_replace(FADEOUT, FADEOUT, "menu_fade_out", false)
	var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)
	if !_crossfade:
		TransitionManager.accept_transition(
			preload("res://engine/components/transitions/circle_transition/circle_transition.tscn")
				.instantiate()
				.with_speeds(999.0, -0.02)
		)
		if TransitionManager.current_transition:
			Audio.play_1d_sound(_sfx, false, { "ignore_pause": true, "bus": "1D Sound" })
			await get_tree().create_timer(1.0, false, false).timeout
			music_loader.play_buffered.call_deferred()
			main_menu_controls.focused = true
			menu_initiated.emit()
		return
	
	Audio.play_1d_sound(_sfx, false, { "ignore_pause": true, "bus": "1D Sound" })
	zoom = Vector2(16, 16)
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.tween_property(self, "zoom", Vector2.ONE, 0.56)
	tw.tween_callback(func():
		music_loader.play_buffered()
		main_menu_controls.focused = true
		menu_initiated.emit()
	)

func _physics_process(delta: float) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
		SettingsManager.show_mouse()
