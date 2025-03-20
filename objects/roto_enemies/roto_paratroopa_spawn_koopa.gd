extends ByNodeScript


func _ready() -> void:
	# node => Koopa
	if node.has_node("Body/EnemyAttacked"):
		node.get_node("Body/EnemyAttacked").stomping_delay.call_deferred()
	
	if node is GeneralMovementBody2D:
		node.look_at_player = false
		node.dir = (vars.enemy_attacked.owner.get(&"dir"))
		node.speed_to_dir()
	
	var enemy_attacked: Node = vars.enemy_attacked
	if !enemy_attacked: return
	var root_node: Node2D = enemy_attacked._center
	var roto: Node = root_node.get_node_or_null("RotoCenter")
	roto.cancel_free()
	root_node.remove_child.call_deferred(roto)
	node.add_child.call_deferred(roto, true)
