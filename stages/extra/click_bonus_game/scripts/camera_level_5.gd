extends "res://objects/player_camera_custom/player_camera_custom.gd"


var target = 480
var amount = 18 * 32
var count = 0
var mov = false

func _ready() -> void:
	super()
	await get_tree().create_timer(3, false, true).timeout
	mov = true

func _physics_process(delta: float) -> void:
	if !mov: return
	count += delta / 5
	offset.x = sin(count) * amount + target
	
