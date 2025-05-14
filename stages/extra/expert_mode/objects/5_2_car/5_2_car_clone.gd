extends GeneralMovementBody2D

const explosion_effect = preload("res://engine/objects/effects/explosion/explosion.tscn")
const EXPLODE = preload("res://sfx/explode.wav")

@export var invincible: bool = false
@export var active: bool = true
@export var activate_collision_after_sec: float = 3

@onready var init_pos := position
@onready var oldspeed: Vector2 = speed
var timer: float = 0
var passive_deactive: bool
@onready var visible_on_screen_enabler_2d: VisibleOnScreenEnabler2D = $VisibleOnScreenEnabler2D
@onready var old_vis_rect: Rect2 = visible_on_screen_enabler_2d.rect
@onready var enemy_attacked: Node = $Body/EnemyAttacked

func _ready() -> void:
	if !active:
		visible = false
	collided_wall.connect(_on_collided_wall, CONNECT_ONE_SHOT)
	if invincible:
		enemy_attacked.stomping_scores = 0
		visible_on_screen_enabler_2d.screen_exited.connect(_on_screen_exited)

func _killnafig() -> void:
	if invincible:
		var pl: Player = Thunder._current_player
		if !pl: return
		NodeCreator.prepare_2d(explosion_effect, pl).create_2d().bind_global_transform()
		return
	explod()


func _physics_process(delta: float) -> void:
	if !active: return
	if passive_deactive:
		visible_on_screen_enabler_2d.rect = old_vis_rect
		
	super(delta)
	if timer < activate_collision_after_sec:
		timer += delta
	elif timer != activate_collision_after_sec * 6:
		timer = activate_collision_after_sec * 6
		collision = true
		set_collision_mask_value(6, true)
		Thunder._connect(collided_wall, _on_collided_wall, CONNECT_ONE_SHOT)


func _on_collided_wall() -> void:
	explod()
	speed = oldspeed
	if invincible:
		visible_on_screen_enabler_2d.rect = old_vis_rect


func explod() -> void:
	var expl = sprite_node.duplicate()
	expl.global_position = global_position + Vector2(16, -28)
	Scenes.current_scene.add_child(expl)
	expl.play("explode")
	expl.z_index = 10
	expl.animation_finished.connect(expl.queue_free, CONNECT_DEFERRED)
	if visible_on_screen_enabler_2d.is_on_screen():
		Audio.play_sound(EXPLODE, self, false)
	reset_car()

func reset_car() -> void:
	timer = 0
	collision = false
	set_collision_mask_value(6, false)
	
	(func():
		position = init_pos
		reset_physics_interpolation()
	).call_deferred()


func activate() -> void:
	visible = true
	active = true


func passive_deactivate() -> void:
	passive_deactive = true

func _on_screen_exited() -> void:
	visible_on_screen_enabler_2d.rect = old_vis_rect
	reset_car()
	
