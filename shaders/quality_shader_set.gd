extends Node2D

@export_category("Keep only on these Quality Settings")
@export var maximum: bool = true
@export var medium: bool = false
@export var minimum: bool = false

@onready var quality: SettingsManager.QUALITY = SettingsManager.settings.quality
@onready var QUALITY = SettingsManager.QUALITY
@onready var old_material: ShaderMaterial = material

func _ready() -> void:
	SettingsManager.settings_updated.connect(_update_visibility)
	_update_visibility()


func _update_visibility() -> void:
	quality = SettingsManager.settings.quality
	var is_shown: bool = (
		(maximum && quality == QUALITY.MAX) ||
		(medium && quality == QUALITY.MID) ||
		(minimum && quality == QUALITY.MIN)
	)
	if is_shown && material == null:
		material = old_material
	if !is_shown:
		material = null
	
