extends Sprite2D

signal lightning_emitted

@export_category("Lightning")
@export_range(0, 1, 0.001, "suffix:s") var lightning_appearing_duration_base: float = 0.4
@export_group("Sound", "sound_")
@export var sound_lightning_list: Array[AudioStream] = [
	preload("res://gfx/effects/lightning/sounds/lightning1.mp3"),
	preload("res://gfx/effects/lightning/sounds/lightning2.mp3"),
]

var _stop: bool
var following: bool

@onready var extension: float = region_rect.size.y
@onready var storm_key_controller: Node = $"../../StormKeyController"


func _ready() -> void:
	visible = false

func _physics_process(delta: float) -> void:
	if following:
		global_position.y = storm_key_controller.key_node.global_position.y - 690

func lightning() -> void:
	if _stop:
		_stop = false
		return
	
	Audio.play_1d_sound(sound_lightning_list.pick_random(), false, {pitch = randf_range(0.75, 1.25)})
	visible = true
	modulate.a = 1
	region_rect.size.y = 0
	following = true
	
	#position.x = randf_range(0, get_viewport_rect().size.x)
	#rotation = randf_range(-PI/4, PI/4)
	#scale = Vector2.ONE * randf_range(0.8, 1)
	lightning_emitted.emit()
	
	global_position.x = storm_key_controller.key_node.global_position.x
	var tw: Tween = create_tween().set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, ^"region_rect:size:y", extension, lightning_appearing_duration_base)
	tw.tween_callback(func() -> void:
		following = false
	)
	tw.tween_property(self, ^"modulate:a", 0.0, 0.5)
	await tw.finished
	
	visible = false


func stop() -> void:
	_stop = true
