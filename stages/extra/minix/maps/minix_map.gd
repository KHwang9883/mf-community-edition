extends Node2D
class_name MinixMap

@export var map_name: String
@export var life_count: int = 1
@export_group("Enemy Spawn Settings", "enemy")
@export var enemy_gravity_scale: float = 0.5
@export var enemy_max_falling_speed: float = 1000
