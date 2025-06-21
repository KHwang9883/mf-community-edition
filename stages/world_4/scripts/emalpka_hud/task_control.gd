extends Control

@export_node_path("Node") var enemy_checker_node_path: NodePath

@onready var enemy_checker: Node = get_node_or_null(enemy_checker_node_path)
@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var enemy_tasks: Array[Node] = h_box_container.get_children()
@onready var player: Player = Thunder._current_player

var occurences: PackedInt32Array = []
var valid_enemies: Array[Node]
var invalid_enemies: Array[bool]

func _ready() -> void:
	occurences.resize(len(enemy_tasks))
	
	recount_enemies.call_deferred(true)
	update_strings.call_deferred(true)
	
	position.y = 104
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "position:y", 0.0, 0.5)


func recount_enemies(init: bool = false) -> void:
	occurences.fill(0)
	for i in enemy_checker.enemies:
		var node = enemy_checker.get_node_or_null(i)
		if !node:
			continue
		for j in len(enemy_tasks):
			if enemy_tasks[j].name in node.name:
				occurences[j] += 1
				if init:
					valid_enemies.append(node)
					invalid_enemies.append(false)


func update_strings(init: bool = false) -> void:
	for j in len(enemy_tasks):
		enemy_tasks[j].get_child(0).text = "~ %d" % occurences[j]
		if occurences[j] == 0 && enemy_tasks[j].modulate.a == 1.0:
			if init:
				enemy_tasks[j].modulate.a = 0.0
				enemy_tasks[j].hide()
			else:
				var tw = enemy_tasks[j].create_tween()
				tw.tween_property(enemy_tasks[j], "modulate:a", 0.0, 0.5)
				tw.tween_callback(enemy_tasks[j].hide)


func _physics_process(delta: float) -> void:
	
	var queue_delete: bool
	for i in len(valid_enemies):
		if is_instance_valid(valid_enemies[i]):
			continue
		if invalid_enemies[i] == false:
			valid_enemies[i] = null
			invalid_enemies[i] = true
			queue_delete = true
	
	if queue_delete:
		recount_enemies()
		update_strings()
	
	if is_instance_valid(player) && player.completed:
		valid_enemies.resize(0)
		player = null
		hide_tasks()


func hide_tasks() -> void:
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "position:y", 128.0, 0.6)
