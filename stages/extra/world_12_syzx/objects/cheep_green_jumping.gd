extends GeneralMovementBody2D

@onready var vision: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D

func _ready() -> void:
	super()
	for i in 2:
		await get_tree().physics_frame
	if !vision.is_on_screen():
		queue_free()

func got_in_water() -> void:
	if speed.y > 0:
		jump(200 + (Thunder.rng.get_randi_range(0, 7) * 50.0))
