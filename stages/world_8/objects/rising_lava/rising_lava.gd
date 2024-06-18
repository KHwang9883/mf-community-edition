extends Node2D

@onready var lava_top_hud = $"../HUD/LavaTopHUD"
@onready var lava_hud = $"../HUD/LavaHUD"
@onready var timer: Timer = $Timer # Timer
@onready var static_body_2d = $"../ParallaxBackground/ParallaxLayer/StaticBody2D"

var lava_speed: int = 0
var player: Player

func _ready():
	player = Thunder._current_player
	timer.timeout.connect(func():
		lava_speed -= 50
	)

func _physics_process(delta):
	if !player: return
	if player.completed && is_instance_valid(static_body_2d):
		static_body_2d.queue_free()
	
	if player.position.y > -7360:
		global_position.y += lava_speed * delta
	
	lava_hud.position.y = lava_top_hud.position.y + (global_position.y - player.global_position.y) / 20

func koniec_gry() -> void:
	var tw = create_tween().set_parallel()
	tw.tween_property(lava_hud, "modulate:a", 0, 2)
	tw.tween_property(lava_top_hud, "modulate:a", 0, 2)
