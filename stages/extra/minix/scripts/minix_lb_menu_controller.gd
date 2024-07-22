extends MenuItemsController

@export var spacing: int = 2
var expanded: Control
var go_back_to: NodePath
var gameover = false

@onready var camera_2d: Camera2D = $"../Selector/Camera2D"


func _physics_process(delta: float) -> void:
	super(delta)
	
	if has_node(prev_screen_node_path) && Input.is_action_just_pressed(prev_screen_control_cancel):
		var lb = Scenes.current_scene.get_node("START/Leaderboard")
		lb.visible = false
		lb.menu_controller.focused = false
		if !gameover:
			var mx = Scenes.current_scene.get_node("START/Node2D/MinixControls")
			mx.focused = true
		else:
			var mx = Scenes.current_scene.get_node("START/GAMEOVER/MinixControls")
			mx.focused = true
		await get_tree().physics_frame
		Pause.get_child(0).open_blocked = false


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
