extends Area2D

@export var enemy_name: String = "CheepYellow"

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area.name != &"Body": return
	var par = area.get_parent()
	if !enemy_name in par.name: return
	var en_att = area.get_node(^"EnemyAttacked")
	en_att.got_killed(&"boomerang")
