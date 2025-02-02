extends Node

@export var max_pos: float = 10000
@export var speed: float = 50

var player
var stopped: bool

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var gpu_particles_2d: GPUParticles2D = $"../HUD/GPUParticles2D"
@onready var gpu_particles_2d_2: GPUParticles2D = $"../HUD/GPUParticles2D2"

func _ready() -> void:
	player = Thunder._current_player

func _physics_process(delta: float) -> void:
	if !player: return
	
	if player.global_position.x > max_pos || stopped:
		stopped = true
		if audio_stream_player.playing:
			audio_stream_player.stop()
		if gpu_particles_2d.emitting:
			gpu_particles_2d.emitting = false
			gpu_particles_2d_2.emitting = false
		return
	
	if player.is_on_wall() && player.left_right == 1: return
	if player.warp != 0: return
	
	player.position.x -= speed * delta
