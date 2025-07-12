extends Node2D

@onready var particles: GPUParticles2D = $Particles


func desparent_particle() -> void:
	particles.reparent.call_deferred(get_parent())
	particles.emitting = false
	get_tree().create_timer(2, false).timeout.connect(particles.queue_free)
