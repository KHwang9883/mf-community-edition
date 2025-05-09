extends GPUParticles2D

@export_category("Rain")
@export_group("Sounds", "sound_")
@export_range(0, 60, 0.001, "suffix:s") var sound_far_lightning_interval_base: float = 12
@export_range(0, 60, 0.001, "suffix:s") var sound_far_lightning_interval_extra: float = 18

@onready var sound: AudioStreamPlayer = $Sound

func _ready() -> void:
	SettingsManager.settings_updated.connect(_update_visibility, CONNECT_DEFERRED)
	_update_visibility.call_deferred()


func _update_visibility() -> void:
	sound.playing = is_visible_in_tree()
	
