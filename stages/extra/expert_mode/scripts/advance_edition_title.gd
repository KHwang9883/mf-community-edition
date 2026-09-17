@warning_ignore("missing_tool")
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
	if MasterChallenge.is_active():
		var start4: Label = $Controls/Start4
		start4.visible = true
		start4.disabled = false
		selector.position_paddings_array = [0.0, 0.0, 0.0, 0.0]
	controls.modulate.a = 0
	selector.modulate.a = 0
	#lostmap_title_press_enter._min_a = 0.7
	
	var tw = create_tween().set_parallel()
	tw.tween_property(controls, "modulate:a", 1, 0.8)
	tw.tween_property(selector, "modulate:a", 1, 0.8)
	
	await get_tree().create_timer(0.8, false).timeout
	controls.focused = true


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
	
	Scenes.goto_scene_with_transition(goto_scene, &"auto", func(t):
		t.with_speeds(5.0, -0.1)
	)
