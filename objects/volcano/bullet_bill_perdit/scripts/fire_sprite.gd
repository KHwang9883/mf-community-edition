extends AnimatedSprite2D

@export var to_dir: int = 1
@onready var bullet_bill: CharacterBody2D = $".."

func _process(delta: float) -> void:
	visible = bullet_bill.dir == to_dir
