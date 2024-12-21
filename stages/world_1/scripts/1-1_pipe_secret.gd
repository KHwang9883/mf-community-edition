extends Node

const LIFE_MUSHROOM = preload("res://engine/objects/powerups/life_mushroom/life_mushroom.tscn")
const POISONOUS_MUSHROOM = preload("res://engine/objects/powerups/poisonous_mushroom/poisonous_mushroom.tscn")
@onready var par = $".."
@onready var text: Sprite2D = $"../../HUD/Sprite2D"


func _ready() -> void:
	if !Data.values.onetime_blocks:
		par.queue_free()
		return
	par.warp_started.connect(_spawn_lives)


func _spawn_lives() -> void:
	var scene = Scenes.current_scene
	var life_spawns = scene.get_node("LifeSpawns")
	for i in life_spawns.get_children():
		var life = LIFE_MUSHROOM.instantiate()
		life.appear_distance = 0
		scene.add_child(life)
		life.global_position = i.global_position + Vector2(0, -16)
		life.reset_physics_interpolation()
	
	var poison_spawns = scene.get_node_or_null("PoisonSpawns")
	if is_instance_valid(poison_spawns):
		for i in poison_spawns.get_children():
			var life = POISONOUS_MUSHROOM.instantiate()
			life.appear_distance = 0
			scene.add_child(life)
			life.global_position = i.global_position + Vector2(0, -16)
			life.reset_physics_interpolation()
	
	text.modulate.a = 1.0
	var tw = create_tween().bind_node(text)
	tw.tween_interval(2.0)
	tw.tween_property(text, "modulate:a", 0.0, 2.0)
