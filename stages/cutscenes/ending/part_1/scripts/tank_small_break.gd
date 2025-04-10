extends Node2D

signal got_broken
@export_enum("middle", "left", "right") var damage_sprite: int = 0
@export var min_delay: int = 1
@export var max_delay: int = 3
@onready var sprite: AnimatedSprite2D = $Sprite

const DAMAGED_TILE = preload("res://stages/cutscenes/ending/part_1/scripts/damaged_tile.tscn")

func _ready() -> void:
	sprite.animation = "default"

func _on_visible_on_screen_enabler_2d_screen_entered():
	await get_tree().create_timer(randi_range(min_delay, max_delay), false).timeout
	
	var inst = DAMAGED_TILE.instantiate()
	inst.position = global_position
	inst.reset_physics_interpolation()
	inst.speed = Vector2(randf_range(-3, 3), randf_range(-5, -12))
	Scenes.current_scene.add_child(inst)
	match damage_sprite:
		0: sprite.animation = "broken"
		1: sprite.animation = "left"
		2: sprite.animation = "right"
	got_broken.emit()
