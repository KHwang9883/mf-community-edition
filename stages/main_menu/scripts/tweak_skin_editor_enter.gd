extends MenuSelection

@onready var value: Label = $Value

func _handle_select() -> void:
	super()
	Scenes.current_scene.get_node("Window").visible = true

func _physics_process(delta: float) -> void:
	super(delta)
	value.visible = focused
