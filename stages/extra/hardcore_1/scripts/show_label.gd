extends Node

@onready var label_2: Label = $"../../HUD/Label2"

func activate() -> void:
	var has_unlocked = SecretsManager.has_secret(get_parent().secrets[0])
	get_parent().unlock_secret()
	if !has_unlocked:
		label_2.activate()
