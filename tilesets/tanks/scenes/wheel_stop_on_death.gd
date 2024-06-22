extends StaticBody2D

@onready var mario = Thunder._current_player
@onready var animated_sprite_2d = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	if is_instance_valid(mario) || !animated_sprite_2d.is_playing(): return
	
	animated_sprite_2d.stop()
