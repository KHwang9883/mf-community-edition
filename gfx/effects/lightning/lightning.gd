extends Sprite2D

signal lightning_emitted

@export_category("Lightning")
@export var lightning_enabled: bool = true
@export_range(0, 20, 0.001, "suffix:s") var lightning_interval_base: float = 3
@export_range(0, 10, 0.001, "suffix:s") var lightning_interval_extra: float = 2
@export_range(0, 1, 0.001, "suffix:s") var lightning_appearing_duration_base: float = 0.1
@export_range(0, 1, 0.001, "suffix:s") var lightning_appearing_duration_extra: float = 0.3
@export_group("Sound", "sound_")
@export var sound_lightning_list: Array[AudioStream] = [
	preload("res://gfx/effects/lightning/sounds/lightning1.mp3"),
	preload("res://gfx/effects/lightning/sounds/lightning2.mp3"),
]

var _stop: bool

@onready var extension: float = region_rect.size.y


func _ready() -> void:
	visible = false
	lightning()


func lightning() -> void:
	await get_tree().create_timer(lightning_interval_base + randf_range(0, lightning_interval_extra), false).timeout
	
	if lightning_enabled:
		if _stop:
			_stop = false
			return
		
		Audio.play_1d_sound(sound_lightning_list.pick_random(), false, {pitch = randf_range(0.75, 1.25)})
		visible = true
		modulate.a = 1
		region_rect.size.y = 0
		
		position.x = randf_range(0, get_viewport_rect().size.x)
		rotation = randf_range(-PI/4, PI/4)
		scale = Vector2.ONE * randf_range(0.8, 1.3)
		lightning_emitted.emit()
		
		var tw: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		tw.tween_property(self, ^"region_rect:size:y", extension, lightning_appearing_duration_base + randf_range(0, lightning_appearing_duration_extra))
		tw.tween_property(self, ^"modulate:a", 0.0, 0.5)
		await tw.finished
		visible = false
	
	lightning()


func stop() -> void:
	_stop = true
