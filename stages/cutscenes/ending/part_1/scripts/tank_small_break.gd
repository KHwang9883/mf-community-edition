extends Node2D

@onready var sprite: AnimatedSprite2D = $Sprite

const DAMAGED_TILE = preload("res://stages/cutscenes/ending/part_1/scripts/damaged_tile.tscn")


func _on_visible_on_screen_enabler_2d_screen_entered():
	await get_tree().create_timer(randi_range(1.2, 3.0), false).timeout
	
	var inst = DAMAGED_TILE.instantiate()
	inst.position = global_position
	inst.reset_physics_interpolation()
	inst.speed = Vector2(randf_range(-3, 3), randf_range(-5, -12))
	Scenes.current_scene.add_child(inst)
	sprite.animation = "broken"
