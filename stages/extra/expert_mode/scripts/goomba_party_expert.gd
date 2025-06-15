extends Node2D

@export var goto_scene: String

@onready var lostmap_title_mario: Sprite2D = $LostmapTitleMario
@onready var label: RichTextLabel = $Label
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var super_mario: Sprite2D = $SuperMario
@onready var super_mario_2: Sprite2D = $SuperMario2
@onready var pause: Label = $CanvasLayer/Pause
@onready var marker_2d: Marker2D = $Marker2D
@onready var marker_2d_2: Marker2D = $Marker2D2
@onready var music_loader: Node = $MusicLoader
@onready var control: Control = $CanvasLayer/Control
@onready var video_stream_player: VideoStreamPlayer = $CanvasLayer/Control/VideoStreamPlayer

const POWERUP = preload("res://engine/objects/players/prefabs/sounds/powerup.wav")

var can_start: bool = false
var pause_tw: Tween
var counter: float

func _ready() -> void:
	label.modulate.a = 0
	lostmap_title_mario.modulate.a = 0
	pause.modulate.a = 0
	control.modulate.a = 0
	var level_to_compl = "res://stages/world_1/expert_level_1-3.tscn"
	if !ProfileManager.current_profile.has_completed(level_to_compl):
		ProfileManager.current_profile.complete_level(level_to_compl)
		ProfileManager.save_current_profile()
	$CanvasLayer/Control/Label.text = "coming\n" + str(Time.get_datetime_dict_from_system().year + 1)
	
	await get_tree().create_timer(1, false).timeout
	can_start = true
	await get_tree().create_timer(3, false).timeout
	var tw = create_tween()
	tw.tween_property(lostmap_title_mario, "modulate:a", 1, 2)
	
	await tw.finished
	_label_fader()

func _label_fader() -> void:
	var tw = create_tween()
	tw.tween_property(label, "modulate:a", 1, 2)


func _physics_process(delta: float) -> void:
	super_mario.position = super_mario.position.move_toward(marker_2d.position, delta * 350)
	super_mario_2.position = super_mario_2.position.move_toward(marker_2d_2.position, delta * 350)
	
	if Input.is_action_just_pressed(&"pause_toggle"):
		if pause_tw: pause_tw.kill()
		pause.modulate.a = 1.0
		pause_tw = pause.create_tween()
		pause_tw.tween_interval(1.0)
		pause_tw.tween_property(pause, ^"modulate:a", 0.0, 0.6)
	
	if can_start && Input.is_action_just_pressed("ui_accept"):
		can_start = false
		var powerup_sfx = CharacterManager.get_sound_replace(POWERUP, POWERUP, "hud_acceptance", false)
		Audio.play_1d_sound(powerup_sfx)
		
		await get_tree().create_timer(1.5, false).timeout
		Audio.stop_music_channel(1, true)
		
		var tw = create_tween()
		tw.tween_property(color_rect, "modulate:a", 1, 1)
		tw.tween_interval(0.5)
		tw.tween_property(control, "modulate:a", 1.0, 1.5)
		tw.tween_interval(1.0)
		tw.tween_callback(func():
			video_stream_player.play()
			get_tree().create_timer(5.8, false, false, true).timeout.connect(start_transition, CONNECT_ONE_SHOT)
		)
		video_stream_player.finished.connect(start_transition)
		
func start_transition() -> void:
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


func _on_timer_timeout() -> void:
	$HBoxContainer.visible = !$HBoxContainer.visible
