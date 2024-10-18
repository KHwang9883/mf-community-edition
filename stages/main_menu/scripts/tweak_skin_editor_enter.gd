extends MenuSelection

@onready var value: Label = $Value

func _handle_select(mouse_input: bool = false) -> void:
	super(mouse_input)
	Scenes.current_scene.get_node("Window").visible = true

func _physics_process(delta: float) -> void:
	super(delta)
	value.visible = focused
