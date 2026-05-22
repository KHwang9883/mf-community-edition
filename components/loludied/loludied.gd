extends CanvasLayer

var active: bool = false
@onready var node_2d = $Node2D
@onready var node_2d2 = $Node2D/Node2D
@onready var color_rect = $Node2D/ColorRect

const LOLUDIED_SONG = preload("res://objects/chorniy_mario/loludied-song.ogg")
# WARNING: This uses LOAD method because when compiling in headless mode, plugins are loaded late
# due to Godot bug, so this is a workaround.
var LOLUDIED_EASTER = load("res://objects/chorniy_mario/pop'n'drop - game over.s3m")

var target_scale = 2
var _current_timer: SceneTreeTimer
var _post_death_timer: SceneTreeTimer

func _ready() -> void:
	node_2d.visible = false
	node_2d2.modulate.a = 0
	color_rect.modulate.a = 0
	node_2d2.scale = Vector2.ONE * 2
	Thunder._connect(Scenes.pre_scene_changed, func():
		if !active && !_post_death_timer: return
		if is_inside_tree():
			deactivate()
		else:
			active = false
	)

func activate(wait_time: float) -> void:
	if _current_timer:
		Thunder._disconnect(_current_timer.timeout, music)
	_current_timer = get_tree().create_timer(wait_time, true, false, true)
	Thunder._connect(_current_timer.timeout, music.bind(wait_time), CONNECT_ONE_SHOT)
	
	_post_death_timer = get_tree().create_timer(0.5, true, false, true)
	Thunder._connect(_post_death_timer.timeout, _post_death_activation, CONNECT_ONE_SHOT)


func _post_death_activation() -> void:
	active = true
	node_2d.visible = true
	get_tree().paused = true
	_timer()
	target_scale = 1.1


func music(wait_time: float = 0.0) -> void:
	await get_tree().create_timer(max(0.52 - wait_time, 0.1), true, false, true).timeout
	if !active: return
	@warning_ignore("incompatible_ternary")
	Audio.play_music(LOLUDIED_SONG if randi_range(1, 100) != 1 else LOLUDIED_EASTER,
		1, {ignore_pause = true})


func deactivate() -> void:
	active = false
	target_scale = 2
	get_tree().paused = false
	if _post_death_timer:
		Thunder._disconnect(_post_death_timer.timeout, _post_death_activation)
	if _current_timer:
		Thunder._disconnect(_current_timer.timeout, music)
	Scenes.custom_scenes.pause.open_blocked = false


func _physics_process(delta: float) -> void:
	node_2d2.scale = lerp(node_2d2.scale, Vector2.ONE * target_scale, 10 * delta)
	
	if active:
		node_2d2.modulate.a = min(node_2d2.modulate.a + 5 * delta, 1)
		color_rect.modulate.a = min(color_rect.modulate.a + 5 * delta, 1)
		
		if Input.is_action_just_pressed(&"ui_cancel") && _current_timer:
			if _current_timer.time_left > 0.0 && is_instance_valid(Audio._music_channels.get(1)):
				Thunder._disconnect(_current_timer.timeout, music)
				_current_timer = null
				Audio._music_channels[1].queue_free()
				@warning_ignore("incompatible_ternary")
				Audio.play_music(LOLUDIED_SONG if randi_range(1, 100) != 1 else LOLUDIED_EASTER,
					1, {ignore_pause = true})
			
		elif Input.is_action_just_pressed("ui_accept") || Input.is_physical_key_pressed(KEY_KP_ENTER):
			Audio.stop_all_sounds()
			deactivate()
			Scenes.reload_current_scene()
			Data.values.onetime_blocks = false
			Thunder._current_player_state = null
			Thunder._current_player_state_path = ""
			ProfileManager.current_profile.data.lives = Data.values.lives
			Data.values.deaths = Data.values.get_or_add("deaths", 0) + 1
			ProfileManager.current_profile.data.deaths = Data.values.deaths
			if !ProfileManager.current_profile.name.begins_with(&"debug"):
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
