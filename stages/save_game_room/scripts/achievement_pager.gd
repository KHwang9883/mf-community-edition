extends Node2D

#@onready var label_5: Label = $"../Objects/Label5"
#@onready var reset: Node2D = $"../CanvasLayer/Reset"
#@onready var left_pager: StaticBumpingBlock = $LeftPager
#@onready var right_pager: StaticBumpingBlock = $RightPager
#@onready var select_a_save_label: Label = $"../Objects/Label5"
#
#@onready var pipe_save: Area2D = $"../PipeSave"
#@onready var pipe_save2: Area2D = $"../PipeSave2"
#@onready var pipe_save3: Area2D = $"../PipeSave4"
#@onready var pipes: Array[Area2D] = [pipe_save, pipe_save2, pipe_save3]
#@onready var pipes_name: Array[String] = [
	#pipes[0].profile_name,
	#pipes[1].profile_name,
	#pipes[2].profile_name
#]
#@onready var pipe_init_y: float = pipe_save.position.y
#
#var page: int = 0
#var total_pages: int = 3
#var tw: Tween
#
#func _ready() -> void:
	#
	#process_mode = PROCESS_MODE_INHERIT
	#show()
	#_update_label_5()
	#left_pager.bumped.connect(left_bumped)
	#right_pager.bumped.connect(right_bumped)
#
#
#func left_bumped() -> void:
	#page = clampi(page - 1, 0, total_pages - 1)
	#if page == 0:
		#left_pager.active = false
	#right_pager.active = true
	#switch_page()
#
#
#func right_bumped() -> void:
	#page = clampi(page + 1, 0, total_pages - 1)
	#if page == total_pages - 1:
		#right_pager.active = false
	#left_pager.active = true
	#switch_page()
#
#
#func switch_page() -> void:
	#for i in len(pipes):
		#pipes[i].position.y = pipe_init_y + 192
		#pipes[i].reset_physics_interpolation()
		#pipes[i].profile_name = pipes_name[i].left(-1) + str(int(pipes_name[i].right(1)) + (page * 3))
		#
		#pipes[i].label.update_label()
		#pipes[i]._update_save()
	#
	#if tw: tw.stop()
	#tw = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_parallel()
	#tw.tween_property(pipe_save, ^"position:y", pipe_init_y, 0.5)
	#tw.tween_property(pipe_save2, ^"position:y", pipe_init_y, 0.5).set_delay(0.1)
	#tw.tween_property(pipe_save3, ^"position:y", pipe_init_y, 0.5).set_delay(0.2)
	#
	#_update_label_5()
#
#
#func _update_label_5() -> void:
	#select_a_save_label.text = "SELECT A SAVE
#page %d / %d" % [page + 1, total_pages]
