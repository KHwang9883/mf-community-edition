extends Area2D


func _on_area_entered(area):
	if "BulletBill" in area.owner.name:
		area.get_node("EnemyAttacked").got_killed("boomerang")
