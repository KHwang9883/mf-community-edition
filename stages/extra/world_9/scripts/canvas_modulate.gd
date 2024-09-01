extends CanvasModulate

var _has_faded: bool
var disabled: bool

@onready var background: Sprite2D = $"../CanvasLayer/Node2D/background"
@onready var point_light_2d: PointLight2D = $"../Mario/PointLight2D"

func _ready() -> void:
	visible = true

func _physics_process(delta: float) -> void:
	var module
	var audio_node: AudioStreamPlayer
	if !Audio._music_channels.has(1): return
	if (
		is_instance_valid(Audio._music_channels[1]) &&
		Audio._music_channels[1].has_meta(&"openmpt")
	):
		audio_node = Audio._music_channels[1]
		module = Audio._music_channels[1].get_meta(&"openmpt")
	
	if _null_check(module): return
	if disabled:
		audio_node.process_mode = Node.PROCESS_MODE_ALWAYS
		return
	var pat = module.get_current_pattern()
	
	audio_node.process_mode = Node.PROCESS_MODE_DISABLED if Scenes.custom_scenes.pause.opened else Node.PROCESS_MODE_ALWAYS
	
	if pat == 4 && !_has_faded:
		_has_faded = true
		color.v = 0.4
		await get_tree().create_timer(0.4, false, false, true).timeout
		disabled = true
		var tw = create_tween().set_parallel()
		var time_scaled: float = 1.2 * Engine.time_scale
		tw.tween_property(background, "modulate:a", 0.8, time_scaled)
		tw.tween_property(point_light_2d, "energy", 0.0, time_scaled)
		tw.tween_property(self, "color", Color(0.7, 0.7, 0.7), time_scaled)



func _null_check(module: Node) -> bool:
	if !module: return true
	if !is_instance_valid(module): return true
	return false
