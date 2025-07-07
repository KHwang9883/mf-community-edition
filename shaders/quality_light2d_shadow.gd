extends PointLight2D

@export_group("Quality Settings")
@export var maximum: bool = true
@export var medium: bool = false
@export var minimum: bool = false
@export var energy_off: float = -1
@export_group("Smooth Appearing")
@export var final_value: float = 1.0
@export var duration: float = 0.2

@onready var init_energy: float = energy
@onready var quality: SettingsManager.QUALITY = SettingsManager.settings.quality
@onready var QUALITY = SettingsManager.QUALITY

func _ready() -> void:
	SettingsManager.settings_updated.connect(_update_visibility)
	_update_visibility()
	
	if duration <= 0: return
	texture_scale = 0.01
	create_tween().tween_property(self, ^"texture_scale", final_value, duration)


func _update_visibility() -> void:
	quality = SettingsManager.settings.quality
	shadow_enabled = (
		(maximum && quality == QUALITY.MAX) ||
		(medium && quality == QUALITY.MID) ||
		(minimum && quality == QUALITY.MIN)
	)
	if energy_off < 0: return
	energy = energy_off if !shadow_enabled else init_energy
