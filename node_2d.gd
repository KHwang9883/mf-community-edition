extends Node2D

func _ready() -> void:
	var file = FileAccess.open("user://testfile.tres", FileAccess.WRITE)
	file.store_var("this is a string")
	file.store_var(0.1)
	file.store_var({"file": true, "hello": "andrew"})
	file.close()

#func _physics_process(delta: float) -> void:
#	var value = floori(log(randi_range(1, 640)) / log(1 - 1/11)) + 1
#	print (value)
