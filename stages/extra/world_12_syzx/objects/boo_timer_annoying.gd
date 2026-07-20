extends Timer

@onready var boo_annoying: Node2D = $"../../BooAnnoying"
@onready var _tweak = ProfileManager.current_profile.data.get("advanced_edition", false)

func _ready() -> void:
	if !_tweak:
		boo_annoying.queue_free()
		return
	timeout.connect(_timeout)
	boo_annoying.hide()

func _timeout() -> void:
	if !is_instance_valid(boo_annoying):
		return
	boo_annoying.position.y -= randf_range(0, 448)
	boo_annoying.reset_physics_interpolation()
	boo_annoying.process_mode = Node.PROCESS_MODE_INHERIT
	boo_annoying.show()
