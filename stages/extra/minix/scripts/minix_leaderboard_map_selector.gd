extends NinePatchRect

const SELECT_ENTER = preload("res://engine/components/ui/_sounds/select_enter.wav")

@onready var menu_items_controller = $"../../MenuItemsController"

@onready var node_2d = $Node2D
@onready var template = $Node2D/Map
@onready var off_size_x = template.size.x
var map_names: Array[String] = []
var map_id: int = 0


func _ready() -> void:
	var starter = Scenes.current_scene.get_node("START/Node2D")
	
	var offset = 0
	
	map_names = starter.map_names.duplicate()
	map_names.push_front("all maps")
	
	for i in map_names:
		var temp_instance = template.duplicate()
		temp_instance.text = i
		temp_instance.position.x = offset
		node_2d.add_child(temp_instance)
		offset += off_size_x
	
	template.queue_free()


func _physics_process(delta: float) -> void:
	var lb = Scenes.current_scene.get_node("START/Leaderboard")
	
	if !menu_items_controller.focused: return
	
	if Input.is_action_just_pressed("ui_right") && !lb.is_loading:
		map_id += 1
		if map_id >= len(map_names):
			map_id = 0
		Audio.play_1d_sound(SELECT_ENTER)
		_update_map()
	
	if Input.is_action_just_pressed("ui_left") && !lb.is_loading:
		map_id -= 1
		if map_id < 0:
			map_id = len(map_names) - 1
		Audio.play_1d_sound(SELECT_ENTER)
		_update_map()
	
	node_2d.position.x = lerp(node_2d.position.x, -(map_id * off_size_x), 20 * delta)


func _update_map() -> void:
	var lb = Scenes.current_scene.get_node("START/Leaderboard")
	
	lb.map_load_name = map_names[map_id]
	
	lb._load_records()
