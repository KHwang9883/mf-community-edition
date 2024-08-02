extends Control

const APPLEUSE = preload("res://stages/extra/click_bonus_game/sfx/appleuse.ogg")
const DISCOVEREDGUNPOWDER_ = preload("res://stages/extra/click_bonus_game/sfx/discoveredgunpowder-.wav")

var _original_time_scale: float

var can_interact = false

@onready var audio_stream_player = $"Heads-Up Display/AudioStreamPlayer"
@onready var music_loader: Node = $MusicLoader
@onready var heads_up_display: CanvasLayer = $"Heads-Up Display"
@onready var blue_rect: ColorRect = $"Heads-Up Display/ColorRect"
@onready var congratulations = $"Heads-Up Display/Congratulations"
@onready var use_mouse = $"Heads-Up Display/UseMouse"
@onready var find_me = $"Heads-Up Display/FindMe"
@onready var path_2d = $"Heads-Up Display/Path2D"

func _enter_tree() -> void:
	print('[Minigame] altered time scale from %s' % Engine.time_scale)
	_original_time_scale = Engine.time_scale
	Engine.time_scale = 1.2

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	congratulations.modulate.a = 0
	use_mouse.modulate.a = 0
	find_me.modulate.a = 0
	
	heads_up_display.visible = true
	audio_stream_player.play()
	
	var tw = create_tween().set_parallel()
	tw.tween_property(blue_rect, "modulate:a", 0.0, 3.0)
	tw.tween_property(use_mouse, "modulate:a", 1.0, 0.5)
	
	await get_tree().create_timer(4, false).timeout
	
	can_interact = true
	
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

func _restore() -> void:
	print('[Minigame] restored time scale %s' % _original_time_scale)
	Engine.time_scale = _original_time_scale
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_timer_timeout() -> void:
	music_loader.play_buffered()

func _complete() -> void:
	Audio.play_1d_sound(APPLEUSE)
	
	var tw = create_tween().set_parallel()
	tw.tween_property(blue_rect, "modulate:a", 1.0, 3.0)
	tw.tween_property(congratulations, "modulate:a", 1.0, 1.0)
	
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
