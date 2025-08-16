extends Node

func _ready() -> void:
	if Data.technical_values.custom_saved_values.get(&"item_replenisher"):
		$"..".queue_free()
