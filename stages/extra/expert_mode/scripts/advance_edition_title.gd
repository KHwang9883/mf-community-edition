extends Stage2D

@export var goto_scene: String

@onready var node_2d: Node2D = $ParallaxBackground/Node2D
#@onready var label: Label = $ParallaxBackground/Label
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var controls: MenuItemsController = $Controls
@onready var selector: MenuSelector = $Selector

const POWERUP = preload("res://engine/objects/players/prefabs/sounds/powerup.wav")

#@onready var initial_label_y = label.global_position.y

var label_text_pointer: int = 0

func _ready() -> void:
	controls.modulate.a = 0
	selector.modulate.a = 0
	#lostmap_title_press_enter._min_a = 0.7
	
	var tw = create_tween().set_parallel()
	tw.tween_property(controls, "modulate:a", 1, 0.8)
	tw.tween_property(selector, "modulate:a", 1, 0.8)
	
	await get_tree().create_timer(0.8, false).timeout
	controls.focused = true
	
	#await tw.finished
	#_label_fader()
#
#func _label_fader() -> void:
	#var tw = create_tween()
	#tw.tween_property(label, "modulate:a", 1, 2)
	#await get_tree().create_timer(4, false).timeout
	#
	#tw = create_tween()
	#tw.tween_property(label, "modulate:a", 0, 2)
	#await tw.finished
	#
	#_label_fader()

func start_selected() -> void:
	if !controls.focused: return
	controls.focused = false
	var _sfx = CharacterManager.get_sound_replace(POWERUP, POWERUP, "hud_acceptance", false)
	Audio.play_1d_sound(_sfx)

	await get_tree().create_timer(1.2, false).timeout
	
	var tw = create_tween()
	tw.tween_property(color_rect, "modulate:a", 1, 1)
	Audio.stop_music_channel(2, true)
	await tw.finished
	
	#ProfileManager.current_profile.data.current_world = goto_scene
	#ProfileManager.save_current_profile()
	
	var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)
	
	if !_crossfade:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
				.instantiate()
				.with_speeds(0.04, -0.1)
				.with_pause()
		)
		
		await TransitionManager.transition_middle
		Scenes.goto_scene(goto_scene)
	else:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
				.instantiate()
				.with_scene(goto_scene)
		)
