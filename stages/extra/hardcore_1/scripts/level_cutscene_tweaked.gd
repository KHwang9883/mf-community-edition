extends LevelCutscene

func _ready() -> void:
	super()
	if Data.values.get("revamp_scene"):
		goto_path = Data.values.revamp_scene
