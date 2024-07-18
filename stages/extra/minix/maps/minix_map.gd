extends Node2D
class_name MinixMap

@export var map_name: String
@export var life_count: int = 1
@export var stop_music_on_death: bool = true
@export var start_again_on_replay: bool = true
@export var game_over_music: Resource
@export_group("Enemy Spawn Settings", "enemy")
@export var enemy_gravity_scale: float = 0.5
@export var enemy_max_falling_speed: float = 1000
