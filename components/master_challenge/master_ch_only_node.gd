extends CanvasItem

@export var only_for_non_master: bool = false

func _ready() -> void:
	var master_only := MasterChallenge.is_active()
	if only_for_non_master:
		master_only = !master_only
	if !master_only:
		hide()
		queue_free()
