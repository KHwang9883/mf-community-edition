extends MenuItemsController

@export var spacing: int = 5
var expanded: Control
var go_back_to: NodePath

@onready var camera_2d: Camera2D = $"../Selector/Camera2D"


func select(node: Control) -> void:
	expanded = node


func _draw() -> void:
	var last_end_achor = Vector2.ZERO
	for child in get_children():
		child.position = last_end_achor
		last_end_achor.y = child.position.y + child.size.y 
		last_end_achor.y += spacing
	
	custom_minimum_size.y = last_end_achor.y #to work with ScrollContainer
	camera_2d.limit_bottom = last_end_achor.y + position.y + spacing


func _physics_process(delta: float) -> void:
	super(delta)
	
