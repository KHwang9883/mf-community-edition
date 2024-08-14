extends Node

@export var secrets: Array[String] = [""]
@export var show_toast: bool = true

func unlock_secret(id: int = 0) -> void:
	if id < len(secrets):
		if secrets[id].is_empty(): return
		SecretsManager.set_secret(secrets[id], true, true, show_toast)
