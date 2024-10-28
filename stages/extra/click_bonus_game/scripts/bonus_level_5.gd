extends "res://stages/extra/click_bonus_game/scripts/bonus_level.gd"

var target = 480
var amount = 18 * 32
var count = 0
var mov = false


func _ready() -> void:
	super()
	await get_tree().create_timer(3, false, true).timeout
	mov = true


func _physics_process(delta: float) -> void:
	count += delta / 5
	position.x = sin(count) * amount - target
