extends Camera2D

@export var margin: int = 24
@onready var tweaks: MenuItemsController = $"../../Tweaks"

func _ready() -> void:
	limit_bottom = (margin * 2) + tweaks.size.y
