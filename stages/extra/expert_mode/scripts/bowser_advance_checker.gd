extends Node

var bowser_1
var bowser_2

@onready var bowser_trigger: Path2D = $".."

var bowsers_dead: bool
var finished: bool

func _ready() -> void:
	bowser_1 = bowser_trigger.trigger_bowser
	bowser_2 = bowser_trigger.trigger_bowser_2


func _physics_process(delta: float) -> void:
	if !bowser_trigger.triggered: return
	
	if !is_instance_valid(bowser_1) && !is_instance_valid(bowser_2) && !bowsers_dead:
		set_deferred(&"bowsers_dead", true)
		bowser_trigger.stop_music()
	
	if bowsers_dead && !finished && get_tree().get_node_count_in_group(&"#bowser_corpse") == 0:
		finished = true
		Scenes.current_scene.finish(true)
