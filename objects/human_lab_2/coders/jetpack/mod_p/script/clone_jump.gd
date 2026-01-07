extends GeneralMovementBody2D

@export var jump_sound: AudioStream
@export var jumping_speed: float = 450

var in_jump: bool

func motion_process(delta: float, slide: bool = false) -> void:
	if !in_jump:
		super(delta, slide)

func jump(_speed: float) -> void:
	in_jump = true
	sprite_node.play(&"default")
	await sprite_node.animation_finished
	in_jump = false
	if jump_sound:
		Audio.play_sound(jump_sound, self)
	super(jumping_speed)
