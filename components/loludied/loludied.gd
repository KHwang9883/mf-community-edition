extends CanvasLayer

var active: bool = false
@onready var node_2d = $Node2D
@onready var node_2d2 = $Node2D/Node2D
@onready var color_rect = $Node2D/ColorRect

const LOLUDIED_SONG = preload("res://objects/chorniy_mario/loludied-song.ogg")

var target_scale = 2
var _current_timer

func _ready() -> void:
	node_2d.visible = false
	node_2d2.modulate.a = 0
	color_rect.modulate.a = 0
	node_2d2.scale = Vector2.ONE * 2

func activate(wait_time: float) -> void:
	if _current_timer:
		Thunder._disconnect(_current_timer.timeout, music)
	_current_timer = get_tree().create_timer(wait_time, true)
	Thunder._connect(_current_timer.timeout, music, CONNECT_ONE_SHOT)
	
	await get_tree().create_timer(0.6, true).timeout
	
	active = true
	node_2d.visible = true
	get_tree().paused = true
	_timer()
	target_scale = 1.1

func music() -> void:
	await get_tree().create_timer(0.3, true).timeout
	if !active: return
	Audio.play_music(LOLUDIED_SONG, 1, {ignore_pause = true})

func deactivate() -> void:
	active = false
	target_scale = 2
	get_tree().paused = false
	if _current_timer:
		Thunder._disconnect(_current_timer.timeout, music)
	Scenes.custom_scenes.pause.open_blocked = false

func _physics_process(delta: float) -> void:
	node_2d2.scale = lerp(node_2d2.scale, Vector2.ONE * target_scale, 10 * delta)
	
	if active:
		node_2d2.modulate.a = min(node_2d2.modulate.a + 5 * delta, 1)
		color_rect.modulate.a = min(color_rect.modulate.a + 5 * delta, 1)
		
		if Input.is_action_just_pressed("ui_accept"):
			deactivate()
			Scenes.reload_current_scene()
			Data.values.onetime_blocks = false
			Thunder._current_player_state = null
			Thunder._current_player_state_path = ""
			ProfileManager.current_profile.data.lives = Data.values.lives
			ProfileManager.save_current_profile()
	else:
		node_2d2.modulate.a = max(node_2d2.modulate.a - 5 * delta, 0)
		color_rect.modulate.a = max(color_rect.modulate.a - 5 * delta, 0)

func _timer() -> void:
	await get_tree().create_timer(0.45, true, false, true).timeout
	
	if active:
		_timer()
	else: return
	
	if target_scale == 1:
		target_scale = 1.1
	else:
		target_scale = 1
