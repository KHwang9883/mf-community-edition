extends PathFollow2D

@export_category("Phantomic Platform")
@export_group("Physics")
@export var max_speed: float = 50
@export var acceleration: float = 100

var speed: float

@onready var platform: AnimatableBody2D = $Platform
@onready var surface: Area2D = $Platform/Surface
@onready var light_forward: PointLight2D = $Platform/LightForward
@onready var light_back: PointLight2D = $Platform/LightBack


func _physics_process(delta: float) -> void:
	var bodies: Array[Node2D] = surface.get_overlapping_bodies()
	var balance: float = 0
	for i in bodies:
		if !i is CharacterBody2D || !i.is_on_floor():
			continue
		balance += to_local(i.global_position).x
	
	if balance != 0:
		speed = move_toward(speed, acceleration * signf(balance), acceleration * delta)
	else:
		speed = move_toward(speed, 0, acceleration * delta)
	
	light_forward.visible = (balance > 0)
	light_back.visible = (balance < 0)
	
	progress += speed * delta
	
	if platform.sync_to_physics:
		platform.global_position = platform.global_position
