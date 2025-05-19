extends Node2D

@export var goto_scene: String

@onready var lostmap_title_press_enter: Sprite2D = $ParallaxBackground/Node2D/LostmapTitlePressEnter
@onready var parallax_layer: ParallaxLayer = $ParallaxBackground/ParallaxLayer
@onready var node_2d: Node2D = $ParallaxBackground/Node2D
@onready var label: Label = $ParallaxBackground/Label
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect

const POWERUP = preload("res://engine/objects/players/prefabs/sounds/powerup.wav")


@onready var initial_label_y = label.global_position.y

var label_text_pointer: int = 0
var can_start: bool = false

func _ready() -> void:
	label.modulate.a = 0
	node_2d.modulate.a = 0
	lostmap_title_press_enter._min_a = 0.7
	
	await get_tree().create_timer(1, false).timeout
	can_start = true
	await get_tree().create_timer(3, false).timeout
	var tw = create_tween().set_parallel()
	tw.tween_property(label, "modulate:a", 1, 2)
	tw.tween_property(node_2d, "modulate:a", 1, 2)
	
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

func _physics_process(delta: float) -> void:
	_border_moving(delta)
	
	if can_start && Input.is_action_just_pressed("ui_accept"):
		can_start = false
		Audio.play_1d_sound(POWERUP)
		Audio.play_1d_sound(CharacterManager.get_voice_line("checkpoint")[1])
		
		await get_tree().create_timer(1.5, false).timeout
		
		var tw = create_tween()
		tw.tween_property(color_rect, "modulate:a", 1, 1)
		await tw.finished
		
		ProfileManager.current_profile.data.current_world = goto_scene
		ProfileManager.save_current_profile()
		
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

func _border_moving(delta: float) -> void:
	parallax_layer.motion_offset.y += 40 * delta
