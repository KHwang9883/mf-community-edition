extends Control

const APPLEUSE = preload("res://stages/extra/click_bonus_game/sfx/appleuse.ogg")
const DISCOVEREDGUNPOWDER_ = preload("res://stages/extra/click_bonus_game/sfx/discoveredgunpowder-.wav")
const MARIO_OHNO = preload("res://music/climbing_minigame/mario_ohno.wav")

@export var try_count: int = 10

var can_interact = false

var _original_time_scale: float

@onready var audio_stream_player = $"Heads-Up Display/AudioStreamPlayer"
@onready var music_loader: Node = $MusicLoader
@onready var heads_up_display: CanvasLayer = $"Heads-Up Display"
@onready var blue_rect: ColorRect = $"Heads-Up Display/ColorRect"
@onready var congratulations = $"Heads-Up Display/Congratulations"
@onready var use_mouse = $"Heads-Up Display/UseMouse"
@onready var find_me = $"Heads-Up Display/FindMe"
@onready var path_2d = $"Heads-Up Display/Path2D"
@onready var try_next_time: Sprite2D = $"Heads-Up Display/TryNextTime"
@onready var h_box_container: HBoxContainer = $"Heads-Up Display/HBoxContainer"
@onready var tries: HBoxContainer = $"Heads-Up Display/Tries"


func _ready() -> void:
	SettingsManager.show_mouse()
	Data.values.bonus_game = false
	var mario: Player = Thunder._current_player
	if is_instance_valid(mario): mario.completed = true
	tries.try_count = try_count

	congratulations.modulate.a = 0
	use_mouse.modulate.a = 0
	find_me.modulate.a = 0

	heads_up_display.visible = true
	audio_stream_player.play()

	var tw = create_tween().set_parallel()
	tw.tween_property(blue_rect, "modulate:a", 0.0, 3.0)
	tw.tween_property(use_mouse, "modulate:a", 1.0, 0.5)
	tw.finished.connect(func():
		can_interact = true
	)

	await get_tree().create_timer(4, false).timeout

	var tw2 = create_tween()
	tw2.tween_property(use_mouse, "modulate:a", 0.0, 1.5)

	path_2d.active = true

	await get_tree().create_timer(2, false).timeout

	if find_me.visible:
		Audio.play_1d_sound(DISCOVEREDGUNPOWDER_)

	var tw3 = create_tween().set_parallel()
	tw3.tween_property(find_me, "modulate:a", 1, 0.3)
	tw3.tween_property(find_me, "position:y", 204, 5)

	await get_tree().create_timer(3, false).timeout
	var tw4 = create_tween()
	tw4.tween_property(find_me, "modulate:a", 0, 0.5)



func complete() -> void:
	set_deferred("can_interact", false)

	await get_tree().create_timer(0.6, false).timeout
	Audio.play_1d_sound(APPLEUSE, true, { ignore_pause = true })

	var tw = create_tween().set_parallel()
	tw.tween_property(blue_rect, "modulate:a", 1.0, 3.0)
	tw.tween_property(congratulations, "modulate:a", 1.0, 1.0)

	_hide_all_text()
	Audio.stop_music_channel(1, true)

	var mario: Player = Thunder._current_player
	if mario:
		mario.reparent(heads_up_display)
		mario.completed = true
		mario.gravity_scale = 0
		mario.vel_set_y(-50)
		mario.collision = false

	for i in 3:
		await get_tree().create_timer(0.6, false, false, true).timeout
		Thunder.add_lives(1, heads_up_display)
		Audio.play_1d_sound(preload("res://engine/objects/players/prefabs/sounds/1up.wav"))

	await get_tree().create_timer(1.2, false).timeout
	switch_scene()


func gameover() -> void:
	set_deferred("can_interact", false)
	Audio.play_1d_sound(MARIO_OHNO)

	var tw = create_tween()
	tw.tween_property(try_next_time, "modulate:a", 1.0, 0.3)

	_hide_all_text()

	await get_tree().create_timer(2.0, false).timeout
	Audio.stop_music_channel(1, true)
	await get_tree().create_timer(1.5, false).timeout
	switch_scene()


func switch_scene() -> void:
	var _crossfade: bool = SettingsManager.get_tweak("replace_circle_transitions_with_fades", false)
	_restore()

	if !_crossfade:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/circle_transition/circle_transition.tscn")
				.instantiate()
				.with_speeds(0.04, -0.1)
				.with_pause()
		)

		await TransitionManager.transition_middle
		Scenes.goto_scene(Scenes.previous_scene_path)
	else:
		TransitionManager.accept_transition(
			load("res://engine/components/transitions/crossfade_transition/crossfade_transition.tscn")
				.instantiate()
				.with_scene(Scenes.previous_scene_path)
		)


func _enter_tree() -> void:
	print('[Minigame] altered time scale from %s' % Engine.time_scale)
	_original_time_scale = Engine.time_scale
	Engine.time_scale = 1.2


func _restore() -> void:
	print('[Minigame] restored time scale %s' % _original_time_scale)
	Engine.time_scale = _original_time_scale
	SettingsManager.show_mouse()


func _on_timer_timeout() -> void:
	music_loader.play_buffered()


func _hide_all_text() -> void:
	var tw2 = create_tween().set_parallel()
	tw2.tween_property(find_me, "modulate:a", 0, 0.1)
	tw2.tween_property(use_mouse, "modulate:a", 0.0, 0.1)
	tw2.tween_property(path_2d, "modulate:a", 0.0, 0.1)

	tw2.finished.connect(
		func():
			find_me.visible = false
			use_mouse.visible = false
			path_2d.visible = false
	)
