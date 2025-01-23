extends Control

const SHADER_CACHER = preload("res://stages/intro/shader_cacher.tscn")

@onready var disclaimer: TextureRect = $CenterContainer/TextureRect
@onready var icon: Sprite2D = $Icon
var loading_finished: bool = false
var loading_init: bool = false

func _ready() -> void:
	SettingsManager.enable_shortcut_scene_change_keys = false
	await get_tree().create_timer(0.6, false, true, false).timeout
	print("[Startup] Compiling shaders...")
	var cacher = SHADER_CACHER.instantiate()
	Scenes.current_scene.add_child(cacher)
	Thunder.reorder_top(cacher)
	loading_init = true


func _physics_process(delta: float) -> void:
	if loading_init && !loading_finished:
		loading_finished = true
		print("[Startup] Waiting for a bit..")
		get_tree().create_timer(0.6, false, true, false).timeout.connect(display_disclaimer)
		print("[Startup] Shader compilation complete!")


func display_disclaimer() -> void:
	icon.queue_free()
	var tw = disclaimer.create_tween()
	tw.tween_property(disclaimer, "modulate:a", 1.0, 0.6)
	tw.tween_interval(2.2)
	tw.tween_property(disclaimer, "modulate:a", 0.0, 0.6)
	tw.tween_callback(transition)
	await get_tree().physics_frame
	SettingsManager.enable_shortcut_scene_change_keys = true


func transition() -> void:
	var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)
	var mainmenu = ProjectSettings.get_setting("application/thunder_settings/main_menu_path")
	if !_crossfade:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
				.instantiate()
				.with_speeds(0.04, -0.1)
				.with_pause()
		)

		await TransitionManager.transition_middle
		Scenes.goto_scene(mainmenu)
	else:
		Scenes.goto_scene(mainmenu)
