extends Node2D

@export var delay_sec: float = 1.4
const CARD = preload("res://objects/otherworld/3.1/card/card.tscn")
const STAKE = preload("res://objects/otherworld/3.1/card/stake.wav")
const SPEEDS = [-110, -70, 70, 110]

@onready var sprite: Sprite2D = $Deck/Sprite

var order: int

func _ready() -> void:
	$Timer.wait_time = delay_sec
	order = randi_range(0, SPEEDS.size() - 1)
	sprite.texture.region.position.x = 71 * order

func _on_timer_timeout() -> void:
	Audio.play_sound(STAKE, self, false)
	NodeCreator.prepare_2d(CARD, self).create_2d().bind_global_transform(Vector2(0, 8)).call_method(
		func(card: Projectile):
			card.belongs_to = Data.PROJECTILE_BELONGS.ENEMY
			card.speed = Vector2(SPEEDS[order], -150)
			card.sprite_node.texture.region.position.x = 71 * order
	)
	order = wrapi(order + 1, 0, SPEEDS.size())
	sprite.texture.region.position.x = 71 * order
