extends Node2D

@onready var _tweak: bool = SettingsManager.get_tweak("additional_save_pipes", false)

@onready var label_5: Label = $"../Objects/Label5"
@onready var reset: Node2D = $"../CanvasLayer/Reset"
#@onready var pipe_save: Area2D = $"../PipeSave"
#@onready var pipe_save_2: Area2D = $"../PipeSave2"
#@onready var pipe_save_4: Area2D = $"../PipeSave4"
#@onready var marker_1: Vector2 = $Marker_1.global_position
#@onready var marker_2: Vector2 = $Marker_2.global_position
#@onready var marker_3: Vector2 = $Marker_3.global_position


func _ready() -> void:
	if !_tweak:
		hide()
		process_mode = PROCESS_MODE_DISABLED
		return
	
	process_mode = PROCESS_MODE_INHERIT
	show()
	
	#label_5.position.x -= 16
	#reset.position.x -= 16
	
	#pipe_save.global_position = marker_1
	#pipe_save_2.global_position = marker_2
	#pipe_save_4.global_position = marker_3
	#pipe_save.reset_physics_interpolation()
	#pipe_save_2.reset_physics_interpolation()
	#pipe_save_4.reset_physics_interpolation()
