extends Path2D

const fish = preload("res://stages/extra/world_9_syzx/nsmbwiiBoneFish1.wav")

signal platform_fall(index: int)

var started_rising: bool
var lava_speed: float
var _sound_played: int

@onready var sound: AudioStreamPlayer = $AudioStreamPlayer
@onready var timer: Timer = $Timer
@onready var lava: Node2D = $"../Parallax2D/Node2D"
@onready var platform_path_gray: PathFollow2D = $PlatformPathGray


func _physics_process(delta: float) -> void:
	if !started_rising: return
	
	if lava_speed != 0.0:
		lava.position.y += delta * lava_speed
		lava.position.y = clampf(lava.position.y, -480, 0)
	
	if platform_path_gray.progress > 332 + 416 && _sound_played == 0:
		_sound_play()
	elif platform_path_gray.progress > 757 + 416 && _sound_played == 1:
		_sound_play()


func _sound_play() -> void:
	_sound_played += 1
	Audio.play_1d_sound(fish, false)
	await get_tree().create_timer(1.0, false).timeout
	platform_fall.emit(_sound_played)


func _start_rising() -> void:
	if started_rising:
		return
	
	started_rising = true
	
	sound.play()
	timer.start()
	if !timer.timeout.is_connected(sound.play):
		timer.timeout.connect(sound.play)
	
	lava_speed = -40


func _stop_rising() -> void:
	if timer:
		timer.stop()
	lava_speed = 40
