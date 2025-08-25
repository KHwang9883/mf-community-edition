extends BowserAttack

@onready var platf: Node2D = $"../../AmazingPlatf"
@onready var platf_collision: int = platf.collision_layer

func start_attack() -> void:
	super()
	middle_attack()


func middle_attack() -> void:
	super()
	
	var tw: Tween = create_tween()
	tw.tween_property(platf, "modulate:a", 0.0, 0.6)
	tw.tween_callback(func():
		platf.collision_layer = 0
		platf.position.y = 592
	)
	tw.tween_callback(end_attack)


func end_attack() -> void:
	super()
	bowser.lock_movement = false
	bowser.lock_direction = false
	bowser.jump_enabled = true
	bowser.sprite.offset.x = 0
	bowser.sprite.play(&"default")
	platf.collision_layer = platf_collision
