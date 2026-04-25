extends AnimatedSprite2D

@onready var sprite: AnimatedSprite2D = $"../Sprite"
@onready var player = Thunder._current_player

func _physics_process(delta: float) -> void:
	if !is_instance_valid(player):
		return
	
	animation = sprite.animation
	frame = sprite.frame
	visible = global_position.x <= player.global_position.x
	sprite.visible = global_position.x > player.global_position.x
