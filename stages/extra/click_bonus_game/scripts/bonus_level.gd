extends Control

var _original_time_scale: float

@onready var music_loader: Node = $MusicLoader
@onready var heads_up_display: CanvasLayer = $"Heads-Up Display"
@onready var blue_rect: ColorRect = $"Heads-Up Display/ColorRect"

func _enter_tree() -> void:
	print('[Minigame] altered time scale from %s' % Engine.time_scale)
	_original_time_scale = Engine.time_scale
	Engine.time_scale = 1.2


func _ready() -> void:
	var tw = create_tween()
	tw.tween_property(blue_rect, "modulate:a", 0.0, 3.0)
	tw.tween_callback(blue_rect.queue_free)



func _restore() -> void:
	print('[Minigame] restored time scale %s' % _original_time_scale)
	Engine.time_scale = _original_time_scale


func _on_timer_timeout() -> void:
	music_loader.play_buffered()
