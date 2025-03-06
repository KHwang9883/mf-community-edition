extends PathFollow2D

@export var speed: float = 150
@onready var animatable_body_2d: AnimatableBody2D = $AnimatableBody2D

func _ready() -> void:
	print(Thunder.Math.add_delimiter("123"))
	print(Thunder.Math.add_delimiter("12345"))
	print(Thunder.Math.add_delimiter("12345678"))
	print(Thunder.Math.add_delimiter("123456789"))
	print(Thunder.Math.add_delimiter("1234567890"))

func _physics_process(delta: float) -> void:
	if !can_process(): return
	
	progress += delta * speed
	if (progress_ratio <= 0 || progress_ratio >= 1): speed *= -1
	if animatable_body_2d.sync_to_physics:
		animatable_body_2d.global_position = global_position
		animatable_body_2d.reset_physics_interpolation()
