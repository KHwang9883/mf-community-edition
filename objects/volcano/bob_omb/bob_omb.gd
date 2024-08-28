extends GeneralMovementBody2D



@export var ignited: bool = false

func _ready() -> void:
	if !ignited: return
	await get_tree().create_timer(3.0, false).timeout
	sprite_node.play("ignited")
	await get_tree().create_timer(2.0, false).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	super(delta)
	if !ignited: return
	
	speed.x = lerp(speed.x, 0, 10 * delta)
	if abs(speed.x) < 35:
		speed.x = 0
