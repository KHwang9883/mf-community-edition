extends Node2D

@onready var toggler: StaticBumpingBlock = $Toggler
@onready var pipe_save: StaticBody2D = $World9
@onready var pipe_save2: StaticBody2D = $World10
@onready var pipe_save3: StaticBody2D = $World12
@onready var pipes: Array[StaticBody2D] = [pipe_save, pipe_save2, pipe_save3]
@onready var pipe_init_y: float = pipe_save.position.y

var page: int = 0
var total_pages: int = 2
var tw: Tween

func _ready() -> void:
	toggler.bumped.connect(_bumped)

func _bumped() -> void:
	var old_page: int = page
	page = wrapi(page - 1, 0, total_pages)
	switch_page(old_page)

func switch_page(old_page: int) -> void:
	if tw: tw.stop()
	tw = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_parallel()
	for i in len(pipes):
		pipes[i].position.y = pipe_init_y + 184
		pipes[i].reset_physics_interpolation()
		var old_page_node = pipes[i].get_node("Page" + str(old_page))
		old_page_node.hide()
		old_page_node.process_mode = Node.PROCESS_MODE_DISABLED
		var new_page_node = pipes[i].get_node("Page" + str(page))
		new_page_node.show()
		new_page_node.process_mode = Node.PROCESS_MODE_INHERIT
	
		tw.tween_property(pipes[i], ^"position:y", pipe_init_y, 0.5).set_delay(0.1 * i)
	
