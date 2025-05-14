extends MenuItemsController

@export var spacing: int = 2
var expanded: Control
var go_back_to: NodePath
var gameover = false

@onready var camera_2d: Camera2D = $"../Camera2D"


func _physics_process(delta: float) -> void:
	super(delta)
	if !focused: return
	
	if has_node(prev_screen_node_path) && Input.is_action_just_pressed(prev_screen_control_cancel):
		var lb = Scenes.current_scene.get_node("START/Leaderboard")
		lb.visible = false
		focused = false
		if !gameover:
			var mx = Scenes.current_scene.get_node("START/Node2D/MinixControls")
			mx.focused = true
			await get_tree().physics_frame
			Pause.get_child(0).open_blocked = false
		else:
			var mx = Scenes.current_scene.get_node("START/GAMEOVER/MinixControls")
			mx.focused = true


func select(node: Control) -> void:
	expanded = node
	#print(node)


func _update_selectors() -> void:
	selectors = []
	for child in get_children():
		if child is HSeparator || child is VSeparator: continue
		if !child.visible: continue
		selectors.push_back(child)
	#await get_tree().process_frame
	#camera_2d.limit_bottom = int(size.y + position.y) + 12

func _draw() -> void:
	var last_end_achor = Vector2.ZERO
	for child in get_children():
		if !child.visible: continue
		child.position = last_end_achor
		last_end_achor.y = child.position.y + child.size.y 
		last_end_achor.y += spacing
	
	custom_minimum_size.y = last_end_achor.y #to work with ScrollContainer
	camera_2d.limit_bottom = max(last_end_achor.y + position.y + spacing, 480)
	#print("CONROLLER")
