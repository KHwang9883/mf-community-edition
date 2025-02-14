extends "res://engine/objects/enemies/bullet_bill/launcher/bullet_launcher.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var shoot_interval_modifier: float = 1
@export var shoot_interval_offset: float = 0

func _ready() -> void:
	animation_player.speed_scale = shoot_interval_modifier
	animation_player.seek(shoot_interval_offset)

func _launch_bullet() -> void:
	if !Thunder.view.is_getting_closer(self, 32): return
	_on_bullet_launched()
