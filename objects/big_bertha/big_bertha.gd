extends GeneralMovementBody2D

@export_node_path("Node2D") var water_node_path: NodePath = ^"../Water"
@export var does_respawn: bool = true
@export var respawn_delay: float = 6
@export var respawn_offset: float = 0
@export var checkpoints_offset: Dictionary = {}

var state: int
var free_roam: bool = true
var cooldown: float = 0.6
var can_eat: bool
var has_eaten: bool

@onready var water_node = get_node_or_null(water_node_path)
@onready var kill_area: Area2D = $KillArea
@onready var trigger: Area2D = $Trigger

func _ready() -> void:
	sprite_node.animation = &"default"
	if Data.values.checkpoint in checkpoints_offset.keys():
		position += checkpoints_offset[Data.values.checkpoint]
		reset_physics_interpolation()
	
	if !Console.debug_mode:
		Scenes.current_scene.get_node("HUD/DebugSpd").hide()


func _physics_process(delta: float) -> void:
	if !water_node: return
	super(delta)
	if !Thunder._current_camera: return
	var cam_center = Thunder._current_camera.get_screen_center_position()
	# If outside of the screen, Bertha's speed will be faster to keep up with the player
	if abs(position.x - cam_center.x) > 330:
		speed.x = clampf(speed.x, -600, 700)
	else:
		speed.x = clampf(speed.x, -500, 500)
	
	var water_pos_y: float = _process_states(delta, cam_center)
	if sprite_node.animation != &"fall":
		sprite_node.animation = &"default" if !can_eat else &"jump"
	
	if Console.debug_mode:
		var hud = Thunder._current_hud
		if hud:
			hud.get_node("DebugSpd").text = "%.1f" % [speed.x]
	var pl: Player = Thunder._current_player
	if !pl: return
	
	if pl.is_dying: has_eaten = true
	
	if cooldown > 0:
		cooldown = move_toward(cooldown, 0, delta)
	elif free_roam && position.y < water_pos_y + 32 && can_eat:
		if trigger.get_overlapping_bodies().has(pl):
			jump(350)
			free_roam = false
			speed.x = 250 if speed.x > 0 else -250
			gravity_scale = 0.35
	
	if can_eat && kill_area.get_overlapping_bodies().has(pl) && !has_eaten:
		has_eaten = true
		pl.no_movement = true
		pl.ignore_input = true
		pl.visible = false
		pl.death_sprite.modulate.a = 0
		var tw: Tween = pl.create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tw.tween_interval(0.6)
		tw.tween_callback(pl.die)
	

func _process_states(delta, cam_center) -> float:
	var water_pos_y: float = water_node.position.y
	if !free_roam && speed.y > 100:
		sprite_node.animation = &"fall"
		if speed.y > 350 && water_pos_y + 16 < position.y:
			sprite_node.animation = &"default"
			free_roam = true
			gravity_scale = 0.0
			cooldown = 0.8
	
	if !free_roam: return water_pos_y
	
	speed.y = move_toward(speed.y, 0, delta * 1250)
	
	var target_y: float = Thunder._current_player.position.y - 16 if Thunder._current_player else water_pos_y + 16
	if target_y < water_pos_y + 16:
		target_y = water_pos_y + 16
	if position.y < water_pos_y + 16:
		position.y = water_pos_y + 16
	else:
		position.y = lerpf(position.y, target_y, ease(delta, 0.25))
	
	var pl_speed = 1 if !Thunder._current_player else 1 + abs(Thunder._current_player.speed.x) / 450
	match state:
		0:
			if position.x > cam_center.x - 128 || has_eaten:
				speed.x = move_toward(speed.x, -350 * pl_speed, delta * 1000)
			else:
				state = 1
				_process_states(delta, cam_center)
		1:
			if position.x < cam_center.x + 128 || has_eaten:
				speed.x = move_toward(speed.x, 350 * pl_speed, delta * 1100 * pl_speed)
			else:
				state = 0
				_process_states(delta, cam_center)
	return water_pos_y


func _on_trigger_player_enter() -> void:
	can_eat = true


func _on_trigger_player_exit() -> void:
	can_eat = false


func set_as_leaving() -> void:
	has_eaten = true
