extends GeneralMovementBody2D

signal life_text_triggered

const DEFAULT_WARP_SOUND = preload("res://engine/objects/players/prefabs/sounds/pipe.wav")

@export var warping_sound: AudioStream = DEFAULT_WARP_SOUND
@export_range(0, 99999, 0.1, "or_greater", "hide_slider", "suffix:px/s²") var deceleration: float = 500

var animate: bool
var entered: bool
var timer_enter: float
var is_grabbed: bool

@onready var grabbable: Node = $GrabbableModifier
@onready var pipe_in: Area2D = $"../PipeInPlaceholder"
@onready var sign_3: Sprite2D = $"../Sign3"
@onready var sign_4: Sprite2D = $"../Sign4"

func _ready() -> void:
	if "special_otherworld_toad" in Data.technical_values && Data.technical_values.special_otherworld_toad:
		queue_free()
		sign_3.queue_free()
		sign_4.queue_free()

func _physics_process(delta: float) -> void:
	if is_grabbed:
		var pl: Player = Thunder._current_player
		if pl:
			z_index = pl.z_index
		return
	super(delta)
	
	speed.x = move_toward(speed.x, 0, deceleration * delta)
	if position.y > 4096: queue_free()
	
	if !animate: return
	if speed.x != 0:
		dir = signi(int(speed.x))
	
	sprite_node.flip_h = dir > 0
	
	if is_on_floor():
		sprite_node.play("stopped")
		sprite_node.play("stopped" if speed.x < 2 else "walking")
	else:
		sprite_node.play("jump")
	
	if entered:
		if timer_enter < 1.5:
			timer_enter = min(timer_enter + delta, 1.5)
			position.y += delta * 50
		elif timer_enter == 1.5:
			timer_enter = 100.0
			Audio.play_1d_sound(preload("res://engine/objects/players/prefabs/sounds/powerup.wav"))
			life_text_triggered.emit()
			Data.technical_values.special_otherworld_toad = true
			if Data.technical_values.remaining_continues != -1:
				Data.technical_values.remaining_continues += 1
			print("added a continue, total: %d" % Data.technical_values.remaining_continues)
	else:
		z_index = 0


func _on_grab_initiated() -> void:
	animate = true
	sprite_node.play("stopped")


func _on_pipe_in_body_entered(body: Node2D) -> void:
	if entered: return
	if body != self: return
	var pl: Player = Thunder._current_player
	if !pl: return
	
	pl.is_holding = false
	pl.holding_item = null
	entered = true
	gravity_scale = 0
	collision = false
	set_collision_mask_value(7, false)
	speed = Vector2.ZERO
	z_index = -5
	
	grabbable._grabbed = false
	is_grabbed = false
	grabbable._follow_progress = false
	grabbable._following_start = false
	grabbable._following = false
	grabbable.grabbing_top_enabled = false
	grabbable.grabbing_side_enabled = false
	
	var pos_tw = create_tween()
	pos_tw.tween_property(self, "global_position", pipe_in.get_node("PosPlayer").global_position, 0.1)
	var _custom_sound = CharacterManager.get_sound_replace(warping_sound, DEFAULT_WARP_SOUND, "pipe_in", true)
	Audio.play_sound(_custom_sound, self, false)


func _on_ungrabbed() -> void:
	is_grabbed = false


func _on_grabbed() -> void:
	is_grabbed = true
