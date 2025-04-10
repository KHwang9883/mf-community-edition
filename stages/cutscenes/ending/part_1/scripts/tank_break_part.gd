extends Area2D

@export var destroy_on_cam_touch: bool = true
@export var min_speed := Vector2(-3, -5)
@export var max_speed := Vector2(3, -12)
@onready var sprite: Sprite2D = $Sprite2D

const EXPLOSION_TANK = preload("res://stages/cutscenes/ending/part_1/scripts/explosion_tank.tscn")
const DAMAGED_TILE = preload("res://stages/cutscenes/ending/part_1/scripts/damaged_tile.tscn")

func _ready():
	if destroy_on_cam_touch:
		area_entered.connect(func(area):
			if area.is_in_group("cam_manager"):
				deploy_and_destroy()
		)

func deploy_and_destroy() -> void:
	deploy()
	visible = false
	queue_free()

func deploy():
	var inst = DAMAGED_TILE.instantiate()
	inst.texture = sprite.texture
	inst.position = global_position
	inst.reset_physics_interpolation()
	inst.speed = Vector2(randf_range(min_speed.x, max_speed.x), randf_range(min_speed.y, max_speed.y))
	Scenes.current_scene.add_child(inst)
	
	var expl = EXPLOSION_TANK.instantiate()
	expl.position = global_position
	expl.reset_physics_interpolation()
	Scenes.current_scene.add_child(expl)
