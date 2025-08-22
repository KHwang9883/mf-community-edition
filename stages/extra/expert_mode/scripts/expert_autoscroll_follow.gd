extends "res://engine/objects/players/player_camera_autoscroll.gd"

signal things_respawned

var notified = false

@onready var finish_line: Node2D = $"../../FinishLine"
@onready var node_extra_enemies: Node2D = %NodeExtraEnemies
@onready var node_no_checkpoint: Node2D = %NodeNoCheckpoint
@onready var no_cp: bool = Data.values.checkpoint == -1
@onready var player_camera_2d: Camera2D = $PlayerCamera2D
@onready var right_area: Area2D = $RightArea
@onready var left_area: Area2D = $LeftArea
@onready var platform_path_cloud_2: PathFollow2D = $"../../PlatformPathCloud2"
@onready var free_after_cp: Node2D = $"../../FreeAfterCP"

var r_area_in: bool
var l_area_in: bool
var area_timer: float

func _ready() -> void:
	scroll_stopped.connect(func() -> void:
		set_speed(100)
	)
	right_area.player_enter.connect(set.bind("r_area_in", true))
	right_area.player_exit.connect(set.bind("r_area_in", false))
	left_area.player_enter.connect(set.bind("l_area_in", true))
	left_area.player_exit.connect(set.bind("l_area_in", false))

func _physics_process(delta: float) -> void:
	if r_area_in && !notified && speed > 1:
		progress += 15 * delta + minf(area_timer, 50.0)
		area_timer += delta * 12.5
	elif l_area_in && notified && speed < -1:
		progress -= 15 * delta + minf(area_timer, 125.0)
		player_camera_2d.border_push_offset = 10
		area_timer += delta * 12
	else:
		area_timer = 0
	
	super(delta)
	if speed < -1 && !notified:
		notified = true
		things_respawned.emit()
		player_camera_2d.enable_left_border_death = false
		player_camera_2d.enable_right_border_death = true
		for i in Scenes.current_scene.get_children():
			if i is GravityBody2D && is_instance_valid(i) && !i is Player:
				if i is Powerup: continue
				i.queue_free.call_deferred()
		
		node_extra_enemies.process_mode = Node.PROCESS_MODE_INHERIT
		node_extra_enemies.visible = true
		node_extra_enemies.position.y = 0
		
		node_no_checkpoint.process_mode = Node.PROCESS_MODE_INHERIT
		node_no_checkpoint.visible = true
		node_no_checkpoint.position.y = 0
		
		if is_instance_valid(platform_path_cloud_2):
			platform_path_cloud_2.queue_free()
		
		if is_instance_valid(free_after_cp):
			free_after_cp.queue_free()
	
		get_tree().create_timer(0.5, false).timeout.connect(func():
			finish_line.position.y = 416
		)


func set_speed(new_speed: float) -> void:
	speed = -new_speed
