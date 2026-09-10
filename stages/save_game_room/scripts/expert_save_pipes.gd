extends Node2D

@onready var toggler: StaticBumpingBlock = $Toggler
@onready var pipe_save: Area2D = $PipeSaveExp1
@onready var pipe_save2: Area2D = $PipeSaveExp2
@onready var pipe_save3: Area2D = $PipeSaveExp3
@onready var pipes: Array[Area2D] = [pipe_save, pipe_save2, pipe_save3]
@onready var pipes_name: Array[String] = [
	pipes[0].profile_name,
	pipes[1].profile_name,
	pipes[2].profile_name
]
@onready var pipe_init_y: float = pipe_save.position.y
@onready var label_expert: Label = $"../Objects/LabelExpert"

var page: int = 0
var total_pages: int = 2
var tw: Tween

func _ready() -> void:
	toggler.bumped.connect(_bumped)
	_update_label_5()

func _bumped() -> void:
	var old_page: int = page
	page = wrapi(page - 1, 0, total_pages)
	switch_page(old_page)

func switch_page(old_page: int) -> void:
	if tw: tw.stop()
	tw = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_parallel()
	for i in len(pipes):
		pipes[i].position.y = pipe_init_y + 216
		pipes[i].reset_physics_interpolation()
		pipes[i].get_node(^"PipeGreen").visible = page == 0
		pipes[i].get_node(^"PipeRed").visible = page > 0
		pipes[i].master_challenge_pipe = page > 0
		
		pipes[i].profile_name = pipes_name[i].left(-1) + str(int(pipes_name[i].right(1)) + (page * 3))
		pipes[i].label.update_label()
		pipes[i]._update_save()
	
		tw.tween_property(pipes[i], ^"position:y", pipe_init_y, 0.5).set_delay(0.1 * i)
	
	_update_label_5()

func _update_label_5() -> void:
	var _text = "SELECT A SAVE"
	if page > 0:
		_text += "\n(MASTER CHALLENGE)"
	label_expert.text = _text
