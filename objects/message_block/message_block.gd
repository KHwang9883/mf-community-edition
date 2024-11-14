extends StaticBumpingBlock

@export_multiline var message: String

const MESSAGE_BLOCK = preload("res://objects/message_block/message_block.wav")

var activated: bool = false

@onready var box: Node2D = $CanvasLayer/Box
@onready var text: Label = $CanvasLayer/Box/Texture/Text

signal message_shown
signal message_hidden

func got_bumped(by: Node2D) -> void:
	if _triggered: return
	if activated: return
	bump(false)
	process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().physics_frame
	show_message.call_deferred()


func _physics_process(delta: float) -> void:
	if !activated: return
	if !get_tree().paused:
		get_tree().paused = true
	if Input.is_action_just_pressed(&"m_jump"):
		hide_message()
		activated = false


func bump(disable: bool, bump_rotation: float = 0, interrupt: bool = false):
	super(disable, bump_rotation, interrupt)


func show_message() -> void:
	message_shown.emit()
	box.scale = Vector2.ZERO
	text.text = message
	process_mode = Node.PROCESS_MODE_ALWAYS
	Audio.play_1d_sound(MESSAGE_BLOCK)
	get_tree().paused = true
	
	#box.reparent(GlobalViewport.vp)
	#box = GlobalViewport.vp.get_node(^"Box")
	#box.position = Thunder._current_camera.get_screen_center_position()
	box.position = Vector2(320, 240) #как же похуй...
	reset_physics_interpolation()
	
	var tw = get_tree().create_tween().bind_node(box).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(box, ^"scale", Vector2.ONE, 0.5)
	tw.tween_callback(func():
		activated = true
		
	)


func hide_message() -> void:
	if !is_instance_valid(box): return
	message_hidden.emit()
	
	var tw = get_tree().create_tween().bind_node(box)
	tw.tween_property(box, ^"scale", Vector2.ZERO, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_callback(func():
		#box.reparent(self)
		#box = $Box
		process_mode = Node.PROCESS_MODE_INHERIT
		get_tree().paused = false
		activated = false
	)
