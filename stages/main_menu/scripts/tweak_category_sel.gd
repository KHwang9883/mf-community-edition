extends MenuSelection

@export_node_path("MenuItemsController") var move_to_path: NodePath
@export_node_path("MenuSelector") var menu_selector_path: NodePath
@export var reset_to: int = 0
@export var show_desc_bool: bool = false

@onready var valu = get_node_or_null(^"Value")
@onready var camera_2d: Camera2D = $"../../Camera2D"
@onready var move_to: MenuItemsController = get_node_or_null(move_to_path)
@onready var selector_to: MenuSelector = get_node_or_null(menu_selector_path)
var _timer: float

signal selection_entered

func _ready() -> void:
	if valu: valu.modulate.a = 0.0

func _physics_process(delta: float) -> void:
	super(delta)
	if !valu:
		return
	if focused:
		_timer += delta * 10
		valu.modulate.a = min((cos(_timer) / 2.5) + 0.6, 1.0)
	else:
		valu.modulate.a = 0.0


func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	selection_entered.emit()
	get_parent().position.x = 1000
	get_parent().reset_physics_interpolation()
	move_to.position.x = 168
	move_to.reset_physics_interpolation()
	get_parent().focused = false
	Scenes.current_scene.get_node("Tweaks/Label2").visible = false
	var old_selector = camera_2d.selector
	camera_2d.menu_controller = move_to
	camera_2d.selector = selector_to
	camera_2d.update_limit()
	camera_2d.reset_physics_interpolation()
	await get_tree().physics_frame
	
	if reset_to >= 0:
		get_parent().move_selector(reset_to, true)
	elif is_instance_valid(old_selector):
		get_parent().move_selector(old_selector._current_item_index, true)
	move_to.focused = true
	get_parent().focused = false
	if show_desc_bool:
		Scenes.current_scene.get_node("Tweaks/Label2").visible = true
