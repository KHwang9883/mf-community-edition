extends PlayerPhysicsModifier

var sliding_sound_interval: SceneTreeTimer

@onready var progress_bar: ProgressBar = $"../BurningSurface/ProgressBar"
@onready var particles: CPUParticles2D = $"../BurningSurface/Particles"
var heat: float

func _physics_process(delta: float) -> void:
	super(delta)
	if is_applied:
		heat = min(heat + 100.0 * delta, 125.0)
		particles.emitting = heat > 20
		if heat >= 100.0:
			player.hurt()
	elif heat > 0:
		heat = max(heat - 50.0 * delta, 0.0)
		particles.emitting = heat > 50
	else:
		particles.emitting = false
	progress_bar.visible = is_applied || heat > 0.0
	progress_bar.value = heat
