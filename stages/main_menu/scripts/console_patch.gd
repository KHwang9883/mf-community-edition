extends Node

func _physics_process(delta: float) -> void:
	var tweak: bool = SecretsManager.is_console_enabled()
	if Console.is_visible() && !tweak:
		Console.hide()
