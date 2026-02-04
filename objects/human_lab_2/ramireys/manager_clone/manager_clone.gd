extends GeneralMovementBody2D

const ATTACK = preload("res://objects/human_lab_2/ramireys/manager_clone/sfx/attack.ogg")
const MANAGER_PROJECTILE = preload("res://objects/human_lab_2/ramireys/manager_clone/manager_projectile.tscn")

@onready var timer: Timer = $Timer
@onready var timer_shooting: Timer = $TimerShooting

var bullets_left: int

func _on_timer_timeout() -> void:
	var pl: Player = Thunder._current_player
	if !pl: return
	
	sprite_node.animation = "shoot"
	sprite_node.frame = 4
	speed.x = 0
	turn_sprite = false
	update_dir()
	sprite_node.flip_h = dir < 0
	
	bullets_left = 3
	timer.start(3.6)
	timer_shooting.start(0.11)


func _on_timer_shooting_timeout() -> void:
	if bullets_left == 0:
		sprite_node.play("default")
		speed.x = 50
		speed_to_dir()
		turn_sprite = true
		return
	
	var bullet = MANAGER_PROJECTILE.instantiate()
	bullet.global_transform = global_transform
	bullet.position.y += 4
	Scenes.current_scene.add_child(bullet)
	bullet.reset_physics_interpolation()
	
	sprite_node.play("shoot")
	update_dir()
	sprite_node.flip_h = dir < 0
	
	bullets_left -= 1
	Audio.play_sound(ATTACK, self, false)
	timer_shooting.start(0.11)
