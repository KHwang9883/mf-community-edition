extends Path2D

@export var first_point: float = 13024
@onready var platf: PathFollow2D = get_child(0)
@onready var bowser: CharacterBody2D = $"../Bowser"
var active: bool = false

func _ready() -> void:
	
	platf.progress = bowser.global_position.x - first_point

func _physics_process(delta: float) -> void:
	if !active: return
	if !is_instance_valid(bowser): return
	platf.progress = bowser.global_position.x - first_point

func _on_bowser_triggered() -> void:
	active = true
