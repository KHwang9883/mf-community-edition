extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

const EXPLOSION_TANK = preload("res://stages/cutscenes/ending/part_1/scripts/explosion_tank.tscn")
const KUFON = preload("res://stages/cutscenes/ending/part_1/scripts/kufon.tscn")

func _ready():
	area_entered.connect(func(area):
		if area.is_in_group("cam_manager"):
			deploy()
			visible = false
			queue_free()
	)


func deploy():
	var kufon = KUFON.instantiate()
	Scenes.current_scene.add_child(kufon)
	kufon.position = global_position
	kufon.vel_set(-Vector2(25, 50) * randf_range(5, 10))
	
	var expl = EXPLOSION_TANK.instantiate()
	expl.position = global_position
	Scenes.current_scene.add_child(expl)
