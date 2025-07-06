extends Node

@export var set_delay_sec: float
@export var set_delay_stopped: float
@export var set_max_on_screen: int

@onready var _tweak = ProfileManager.current_profile.data.get("advanced_edition", false)
@onready var node: Node = $".."

func _ready() -> void:
	if !_tweak: return
	
	node.delay_sec = set_delay_sec
	node.delay_stopped_sec = set_delay_stopped
	node.max_on_screen = set_max_on_screen
