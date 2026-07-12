extends Node2D

@onready var area_2d: Area2D = $WaterMin/Area2D

@export var disable_collision: bool = false

func _ready() -> void:
	if disable_collision:
		area_2d.can_swim = false
