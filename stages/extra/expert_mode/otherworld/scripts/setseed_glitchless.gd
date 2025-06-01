extends Node

@export var seed_value: int = 100

func _enter_tree() -> void:
	Thunder.rng.set_seed(seed_value)
	print("Random set.")

func _exit_tree() -> void:
	Thunder.rng.randomize_seed()
	print("Random returned to normal")
