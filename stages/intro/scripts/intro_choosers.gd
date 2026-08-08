extends Control

const SCORING = preload("res://engine/components/hud/sounds/scoring.wav")

enum GameStyle {
	RECOMMENDED,
	CLASSIC,
	CUSTOM
}

enum GameLook {
	MODERN,
	SOFTENDO,
	CLASSIC
}

@onready var game_style: MenuItemsController = $ControlStyle/GameStyle
@onready var game_look: MenuItemsController = $ControlLook/GameLook
@onready var control_style: Control = $ControlStyle
@onready var control_look: Control = $ControlLook
@onready var bg: Control = $ControlLook/BG
var look_screenshot_index: int
var look_scr_tween: Tween

func on_choosed(is_game_style: bool, selection_style: GameStyle, selection_look: GameLook):
	if is_game_style:
		game_style.focused = false
		if selection_style == GameStyle.CUSTOM:
			var tw = create_tween().set_trans(Tween.TRANS_CUBIC)
			tw.tween_property(control_style, "position:x", -640, 0.5).set_ease(Tween.EASE_IN)
			tw.tween_property(control_look, "position:x", 0, 0.5).set_ease(Tween.EASE_OUT)
			tw.tween_callback(func():
				game_look.focused = true
			)
		else:
			_apply_style_tweaks(selection_style)
			end()
		return
	
	_apply_look_tweaks(selection_look)
	end()


const CHECKS = {
	0: [0, 0, 0, 0, 0, 0, 1, 0, 0, 1],
	1: [1, 1, 1, 1, 1, 1, 0, 1, 1, 1],
	2: [2, 0, 0, 1, 0, 2, 1, 2, 2, 0],
}

func _on_game_style_selected(item_index: int, item_node: Control, immediate: bool, mouse_input: bool) -> void:
	var checks = $ControlStyle/HBoxContainer/Checks.get_children()
	var checks_2 = $ControlStyle/HBoxContainer/Checks2.get_children()
	for i in checks.size():
		if !checks[i] is Control: continue
		checks[i].get_child(0).frame = CHECKS[item_index][i]
	for i in checks_2.size():
		if !checks_2[i] is Control: continue
		checks_2[i].get_child(0).frame = CHECKS[item_index][i + 5]


func _apply_style_tweaks(style: GameStyle) -> void:
	var is_recommended: bool = style == GameStyle.RECOMMENDED
	var _tweaks: Dictionary = {}
	
	_tweaks.additional_save_pipes = is_recommended
	_tweaks.crouch_jumping = is_recommended
	_tweaks.enable_blur_transitions = is_recommended
	_tweaks.enable_smooth_cam_transitions = is_recommended
	_tweaks.player_skid_animation = is_recommended
	_tweaks.remade_levels = is_recommended
	_tweaks.bowser_stomping = not is_recommended
	_tweaks.stomping_combo = is_recommended
	_tweaks.minigames_in_main_worlds = is_recommended
	print("[Intro] Selected Style is Recommended: %s" % is_recommended)
	
	# Both Recommended and Classic style options
	_tweaks.show_warning_on_revamped_levels = false
	_tweaks.show_warning_on_improved_levels = false
	
	for i in _tweaks.keys():
		SettingsManager.set_tweak(i, _tweaks[i])


func _apply_look_tweaks(look: GameLook) -> void:
	var _tweaks: Dictionary = {}
	match look:
		GameLook.MODERN:
			SettingsManager.settings.quality = SettingsManager.QUALITY.MID
			_tweaks.player_skid_animation = true
			_tweaks.bgm_as_in_version = 0
			print("[Intro] Selected Game Look: Modern")
		GameLook.SOFTENDO:
			SettingsManager.settings.quality = SettingsManager.QUALITY.MAX
			_tweaks.replace_circle_transitions_with_fades = true
			_tweaks.bgm_fade_in_bug_emulation = true
			_tweaks.alt_completion_music = true
			_tweaks.vignette = true
			_tweaks.bgm_as_in_version = 3
			print("[Intro] Selected Game Look: Softendo")
		GameLook.CLASSIC:
			SettingsManager.settings.quality = SettingsManager.QUALITY.MIN
			_tweaks.enable_blur_transitions = false
			_tweaks.enable_smooth_cam_transitions = false
			_tweaks.bgm_as_in_version = 1
			print("[Intro] Selected Game Look: Classic")
	
	_tweaks.show_warning_on_revamped_levels = true
	_tweaks.show_warning_on_improved_levels = true
	
	for i in _tweaks.keys():
		SettingsManager.set_tweak(i, _tweaks[i])

func _physics_process(delta: float) -> void:
	if !game_look.focused: return
	
	if Input.is_action_just_pressed(&"ui_left"):
		look_screenshot_index = wrapi(look_screenshot_index - 1, 0, 3)
		look_toggled()
	elif Input.is_action_just_pressed(&"ui_right"):
		look_screenshot_index = wrapi(look_screenshot_index + 1, 0, 3)
		look_toggled()

func _on_game_look_selected(item_index: int, item_node: Control, immediate: bool, mouse_input: bool) -> void:
	if immediate: return
	match item_index:
		0:
			bg.get_child(0).texture = load("res://stages/intro/textures/scr2.png")
			bg.get_child(1).texture = load("res://stages/intro/textures/scr4.png")
			bg.get_child(2).texture = load("res://stages/intro/textures/scr6.png")
		1:
			bg.get_child(0).texture = load("res://stages/intro/textures/scr1.png")
			bg.get_child(1).texture = load("res://stages/intro/textures/scr4.png")
			bg.get_child(2).texture = load("res://stages/intro/textures/scr7.png")
		2:
			bg.get_child(0).texture = load("res://stages/intro/textures/scr2.png")
			bg.get_child(1).texture = load("res://stages/intro/textures/scr3.png")
			bg.get_child(2).texture = load("res://stages/intro/textures/scr5.png")

func look_toggled() -> void:
	if look_scr_tween && look_scr_tween.is_valid():
		look_scr_tween.kill()
	Audio.play_1d_sound(SCORING, true, {ignore_pause = true})
	look_scr_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	look_scr_tween.tween_property(bg, "position:x", -640 * look_screenshot_index, 0.4)

func end() -> void:
	SettingsManager.save_settings()
	SettingsManager.save_tweaks()
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	tw.tween_callback(Scenes.current_scene.transition)
