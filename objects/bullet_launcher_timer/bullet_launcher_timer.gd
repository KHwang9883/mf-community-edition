extends "res://engine/objects/enemies/bullet_bill/launcher/bullet_launcher.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var shoot_interval_modifier: float = 1
@export var shoot_interval_offset: float = 0
@export var use_getting_closer: bool = true
@onready var left: Sprite2D = $CanvasGroup/Left
@onready var right: Sprite2D = $CanvasGroup/Right

func _ready() -> void:
	animation_player.speed_scale = shoot_interval_modifier
	animation_player.seek(shoot_interval_offset)

func _launch_bullet() -> void:
	if !Thunder.view.is_getting_closer(self, 32) && use_getting_closer: return
	_on_bullet_launched()

func _create_bullet() -> NodeCreator.NodeCreation:
	reset_anim()
	return super()

func stop_anim() -> void:
	left.visible = false
	right.visible = false

func reset_anim() -> void:
	left.visible = true
	right.visible = true

func _on_screen_entered() -> void:
	return
