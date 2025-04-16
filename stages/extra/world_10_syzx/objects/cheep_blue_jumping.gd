extends GeneralMovementBody2D

@onready var vision: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D

func _ready() -> void:
	for i in 2:
		await get_tree().physics_frame
	if !vision.is_on_screen():
		queue_free()
