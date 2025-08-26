extends BowserAttack

@onready var platf: Node2D = $"../../AmazingPlatf"
@onready var body_1: AnimatableBody2D = $"../../AmazingPlatf/Body1"
@onready var body_2: AnimatableBody2D = $"../../AmazingPlatf/Body2"

func start_attack() -> void:
	super()
	middle_attack()


func middle_attack() -> void:
	super()
	
	var tw: Tween = create_tween()
	tw.tween_property(platf, "modulate:a", 0.0, 0.6)
	tw.tween_callback(func():
		platf.position.y = 592
	)
	tw.tween_callback(end_attack)
	await get_tree().create_timer(0.4, false, false).timeout
	body_1.set_deferred(&"collision_layer", 0)
	body_2.set_deferred(&"collision_layer", 0)
	bowser.speed.y = 0
	


func end_attack() -> void:
	super()
	bowser.lock_movement = false
	bowser.lock_direction = false
	bowser.jump_enabled = true
	bowser.sprite.offset.x = 0
	bowser.sprite.play(&"default")
	bowser.vel_set_x(bowser._speed * bowser.direction)
	body_1.collision_layer = body_1.collision_layer_ori
	body_2.collision_layer = body_2.collision_layer_ori
	
