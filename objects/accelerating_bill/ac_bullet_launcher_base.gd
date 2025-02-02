extends Sprite2D

@onready var collision_shape_2d: CollisionShape2D = $AcceleratingBillLauncherBase/CollisionShape2D


func _ready() -> void:
	var shape: RectangleShape2D = collision_shape_2d.shape.duplicate(true)
	shape.size.y = region_rect.size.y
	collision_shape_2d.position.y = shape.size.y / 2 + offset.y
	collision_shape_2d.set_deferred(&"shape", shape)
