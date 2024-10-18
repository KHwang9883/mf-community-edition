extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $WaterMin/Area2D/CollisionShape2D

@export var disable_collision: bool = false

func _ready() -> void:
	if disable_collision:
		collision_shape_2d.disabled = true
