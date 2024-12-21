extends "res://engine/objects/players/player_camera_autoscroll.gd"

signal things_respawned

var notified = false

@onready var finish_line: Node2D = $"../../FinishLine"
@onready var node_extra_enemies: Node2D = %NodeExtraEnemies
@onready var node_no_checkpoint: Node2D = %NodeNoCheckpoint
@onready var no_cp: bool = Data.values.checkpoint == -1


func _ready() -> void:
	scroll_stopped.connect(func() -> void:
		set_speed(100)
	)

func _physics_process(delta: float) -> void:
	super(delta)
	if speed < -1 && !notified:
		notified = true
		finish_line.position.y = 416
		node_extra_enemies.process_mode = Node.PROCESS_MODE_INHERIT
		node_extra_enemies.visible = true
		node_extra_enemies.position.y = 0
		if no_cp:
			node_no_checkpoint.process_mode = Node.PROCESS_MODE_INHERIT
			node_no_checkpoint.visible = true
			node_extra_enemies.position.y = 0


func set_speed(new_speed: float) -> void:
	speed = -new_speed
