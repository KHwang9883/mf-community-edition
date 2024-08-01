extends Camera2D

@onready var music_loader: Node = $"../Menu/MusicLoader"
@onready var main_menu_controls: MenuItemsController = $"../Menu/MainMenuControls"

const FADEOUT = preload("res://engine/components/ui/_sounds/fadeout.wav")

func _ready() -> void:
	var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)
	if !_crossfade:
		music_loader.play_buffered.call_deferred()
		main_menu_controls.focused = true
		return
	
	Audio.play_1d_sound(FADEOUT)
	zoom = Vector2(16, 16)
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.tween_property(self, "zoom", Vector2.ONE, 0.5)
	tw.tween_callback(func():
		music_loader.play_buffered()
		main_menu_controls.focused = true
	)
