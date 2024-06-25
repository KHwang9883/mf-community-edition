extends ParallaxBackground


@onready var back_clouds = $BackClouds
@onready var front_clouds = $FrontClouds

var fade_clouds: bool = false

func _physics_process(delta: float) -> void:
	if fade_clouds:
		back_clouds.modulate.a -= delta * 0.9
		front_clouds.modulate.a -= delta * 0.9
