extends Camera2D

signal menu_initiated

const _OFFSCREEN_MENUS: Array[NodePath] = [^"Settings", ^"Controls", ^"Tweaks"]

@onready var music_loader: Node = $"../Menu/MusicLoader"
@onready var main_menu_controls: MenuItemsController = $"../Menu/MainMenuControls"

const FADEOUT = preload("res://engine/components/ui/_sounds/fadeout.wav")

func _ready() -> void:
	Scenes.custom_scenes.pause.open_blocked = false
	make_current()
	# Off-screen panels interpolate from (0, 0) for one frame on reload.
	# Hide them before the first draw when skipping the cover circle.
	if Data.technical_values.get("_skip_menu_transition", false):
		Data.technical_values.erase("_skip_menu_transition")
		_set_offscreen_menus_visible(false)
		_reset_menu_interpolation()
		await get_tree().physics_frame
		_set_offscreen_menus_visible(true)
		_reset_menu_interpolation()
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


func _set_offscreen_menus_visible(_is_visible: bool) -> void:
	var root := get_parent()
	if !root:
		return
	for menu_name in _OFFSCREEN_MENUS:
		var node: Node = root.get_node_or_null(menu_name)
		if node is CanvasItem:
			node.visible = _is_visible


func _reset_menu_interpolation() -> void:
	make_current()
	reset_physics_interpolation()
	var root := get_parent()
	if !root:
		return
	root.reset_physics_interpolation()
