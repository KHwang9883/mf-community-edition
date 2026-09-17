extends Node2D

@export var goto_scene: String

@onready var lostmap_title_mario: Sprite2D = $LostmapTitleMario
@onready var lostmap_title_press_enter: Sprite2D = $ParallaxBackground/Node2D/LostmapTitlePressEnter
@onready var parallax_layer: ParallaxLayer = $ParallaxBackground/ParallaxLayer
@onready var node_2d: Node2D = $ParallaxBackground/Node2D
@onready var label: RichTextLabel = $ParallaxBackground/Label
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var label_2: RichTextLabel = $ParallaxBackground/Label2

const POWERUP = preload("res://engine/objects/players/prefabs/sounds/powerup.wav")

var label_template = "[center][i]%s"

var label_texts = [
	"
HELLO IN MARIO
FOREVER THE LOST MAP!",
	"THIS IS A SMALL
ONLINE GAME BASED ON
MARIO FOREVER GAME",
	"
YOU WON'T FIND
THIS IN NORMAL GAME",
	"YOU'VE HERE A
SPECIAL MAP TO
COMPLETE.",
	"
HAVE A NICE
PLAYING TIME."
]

var label_offsets = [
	0,
	8,
	1,
	9,
	-7
]

var label_font_sizes = [
	10,
	10,
	10,
	10,
	13
]

@onready var initial_label_y = label.global_position.y

var label_text_pointer: int = 0
var can_start: bool = false
var _counter: float

func _ready() -> void:
	lostmap_title_mario.modulate.a = 0
	node_2d.modulate.a = 0
	lostmap_title_press_enter._min_a = 0.7
	
	label.modulate.a = 0
	label_2.modulate.a = 0
	label_2.visible = false
	label.global_position.y = initial_label_y + label_offsets[label_text_pointer]
	label.text = label_template % label_texts[label_text_pointer]
	
	await get_tree().create_timer(1, false).timeout
	can_start = true

func _mario_appear() -> void:
	var tw = create_tween().set_parallel()
	tw.tween_property(lostmap_title_mario, "modulate:a", 1.0, 2.0)
	tw.tween_property(node_2d, "modulate:a", 1.0, 2.0)
	
	await tw.finished
	_label_fader()


func _label_fader() -> void:
	var tw = create_tween().set_parallel()
	tw.tween_property(label, "modulate:a", 1.0, 1.0).from(0.0)
	tw.tween_property(label_2, "modulate:a", 0.0, 1.0).from(1.0)
	await get_tree().create_timer(4, false).timeout
	
	label_2.global_position = label.global_position
	label_2.text = label.text
	label_2.add_theme_font_size_override("italics_font_size", label_font_sizes[label_text_pointer])
	label_2.visible = true
	
	label_text_pointer += 1
	if label_text_pointer >= len(label_texts):
		label_text_pointer = 0
	label.global_position.y = initial_label_y + label_offsets[label_text_pointer]
	label.text = label_template % label_texts[label_text_pointer]
	label.add_theme_font_size_override("italics_font_size", label_font_sizes[label_text_pointer])
	
	_label_fader()

func _physics_process(delta: float) -> void:
	_border_moving(delta)
	
	if _counter >= 0:
		_counter += delta
	if _counter > 3.0:
		_counter = -1
		_mario_appear()
	
	if can_start && Input.is_action_just_pressed("ui_accept"):
		can_start = false
		var _sfx = CharacterManager.get_sound_replace(POWERUP, POWERUP, "hud_acceptance", false)
		Audio.play_1d_sound(_sfx)
		Audio.play_1d_sound(CharacterManager.get_voice_line("checkpoint")[0])
		
		await get_tree().create_timer(1.5, false).timeout
		
		var tw = create_tween()
		tw.tween_property(color_rect, "modulate:a", 1.0, 1.0)
		await tw.finished
		
		Scenes.goto_scene_with_transition(goto_scene, &"auto", func(t):
			t.with_speeds(5.0, -0.1)
		)

func _border_moving(delta: float) -> void:
	parallax_layer.motion_offset.y += 40 * delta

func _input(event: InputEvent) -> void:
	if event is InputEventKey || event is InputEventJoypadButton:
		if !event.is_pressed(): return
		if _counter >= 0:
			_mario_appear()
			_counter = -1
