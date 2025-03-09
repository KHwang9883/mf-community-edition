extends Node2D

@onready var cam_area: Control = $"../CamArea"
var activated: bool = false
var no_control: bool
@onready var music_loader: Node = $"../MusicLoader"
@onready var expl: AnimatedSprite2D = $expl
@onready var platform_path_gray: PathFollow2D = $PlatformPathGray

@onready var art: Sprite2D = $art
@onready var art_2: Sprite2D = $art2
@onready var art_3: Sprite2D = $art3
@onready var marker_2d: Marker2D = $Marker2D

@onready var camera_area: Control = $"../CameraArea"

func _ready() -> void:
	expl.hide()
	if SecretsManager.is_console_enabled():
		cam_area.queue_free()
		platform_path_gray.position.y += 64
		platform_path_gray.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		cam_area.view_section_changed.connect(activate, CONNECT_ONE_SHOT)



func activate() -> void:
	if activated: return
	activated = true
	
	music_loader.pause_music()
	Thunder._current_hud.hide()
	Data.values.time += 16
	if Thunder._current_player:
		Thunder._current_player.ignore_input = true
	await get_tree().create_timer(1.0, false, false).timeout
	camera_area.view_section_changed.connect(func() -> void:
		Audio.stop_all_sounds()
		music_loader.unpause_music()
		Thunder._current_hud.show()
	, CONNECT_ONE_SHOT)
	await get_tree().create_timer(0.5, false, false).timeout
	Audio.play_sound(preload("res://objects/chorniy_mario/death_sounds/very_new/sfx_logo.ogg"), marker_2d, false, {bus = "1D Sound"})
	$AnimationPlayer.play(&"new_animation")
	
	await get_tree().create_timer(6.0, false, false).timeout
	Audio.play_sound(preload("res://sfx/explode.wav"), marker_2d, false)
	if Thunder._current_player:
		Thunder._current_player.jump(37*50)
		Thunder._current_player.ignore_input = false
		
	expl.play(&"explode")
	expl.show()
	platform_path_gray.show()
	platform_path_gray.process_mode = Node.PROCESS_MODE_INHERIT
