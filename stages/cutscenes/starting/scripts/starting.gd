extends Node2D

@onready var canvas_layer = $CanvasLayer

@onready var skip_layer = $CanvasLayer/ColorRect2
@onready var buziol_layer = $CanvasLayer/ColorRect
@onready var buziol_animation_player = $CanvasLayer/ColorRect/AnimationPlayer
@onready var transition_layer = $CanvasLayer/ColorRect3
@onready var originally_created_label = $CanvasLayer/ColorRect/Label5

@onready var music_loader = $MusicLoader

@onready var main_camera_path = $Path2D/PathFollow2D
@onready var clouds_bg = $ParallaxBackground
@onready var second_camera_path = $Path2D2/PathFollow2D
@onready var second_camera = $Path2D2/PathFollow2D/Camera2D

var _original_time_scale: float

func _ready() -> void:
	_flow_intros()

func _enter_tree() -> void:
	_original_time_scale = Engine.time_scale
	Engine.time_scale = 1

func _exit_tree() -> void:
	Engine.time_scale = _original_time_scale

func _flow_intros() -> void:
	# INTRO
	
	canvas_layer.visible = false
	# godot moment
	originally_created_label.size = Vector2(640, 128)
	
	#await get_tree().create_timer(3.2, false).timeout
	#skip_layer.out = true
	
	#await get_tree().create_timer(1, false).timeout
	#buziol_animation_player.play("appear")
	
	#await get_tree().create_timer(2, false).timeout
	#buziol_layer.out = true
	
	#await get_tree().create_timer(0.8, false).timeout
	#transition_layer.out = true
	
	#await get_tree().create_timer(0.4, false).timeout
	music_loader.play_buffered()
	
	# MAIN INTRO
	
	await get_tree().create_timer(5, false).timeout
	var tw = create_tween()
	tw.tween_property(main_camera_path, "speed", 230, 1.8)
	
	await get_tree().create_timer(32, false).timeout
	
	clouds_bg.fade_clouds = true
	var tw2 = create_tween()
	tw2.tween_property(main_camera_path, "speed", 830, 1.8)
	
	await get_tree().create_timer(1.4, false).timeout
	main_camera_path.queue_free()
	second_camera.enabled = true
	second_camera_path.speed = 630
	
	await get_tree().create_timer(0.1, false).timeout
	var tw3 = create_tween()
	tw3.tween_property(second_camera_path, "speed", 60, 1.5)
