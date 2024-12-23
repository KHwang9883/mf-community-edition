extends "res://engine/objects/players/player_camera_autoscroll.gd"

signal things_respawned

var notified = false

@onready var finish_line: Node2D = $"../../FinishLine"
@onready var node_extra_enemies: Node2D = %NodeExtraEnemies
@onready var node_no_checkpoint: Node2D = %NodeNoCheckpoint
@onready var no_cp: bool = Data.values.checkpoint == -1
@onready var player_camera_2d: Camera2D = $PlayerCamera2D


func _ready() -> void:
	scroll_stopped.connect(func() -> void:
		set_speed(100)
	)

func _physics_process(delta: float) -> void:
	super(delta)
	if speed < -1 && !notified:
		notified = true
		player_camera_2d.enable_left_border_death = false
		player_camera_2d.enable_right_border_death = true
		for i in Scenes.current_scene.get_children():
			if i is GravityBody2D && is_instance_valid(i) && !i is Player:
				i.queue_free.call_deferred()
		
		node_extra_enemies.process_mode = Node.PROCESS_MODE_INHERIT
		node_extra_enemies.visible = true
		node_extra_enemies.position.y = 0
		#if no_cp:
		node_no_checkpoint.process_mode = Node.PROCESS_MODE_INHERIT
		node_no_checkpoint.visible = true
		node_no_checkpoint.position.y = 0
	
		get_tree().create_timer(0.5, false).timeout.connect(func():
			finish_line.position.y = 416
		)


func set_speed(new_speed: float) -> void:
	speed = -new_speed
