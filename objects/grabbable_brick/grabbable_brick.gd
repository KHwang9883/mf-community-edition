extends StaticBody2D

enum SPRITE_TYPES {
	DEFAULT,
	DARK
}

@export var sprite_type: SPRITE_TYPES = SPRITE_TYPES.DEFAULT

const DARK_BRICK = preload("res://objects/grabbable_brick/textures/dark_brick.png")

var result = preload("res://objects/grabbable_brick/holding_grabbable_brick.tscn")
var based: Node2D
@onready var player: Player = Thunder._current_player as Player
@onready var sprite: Sprite2D = $Sprite2D as Sprite2D

func _ready() -> void:
	if sprite_type == SPRITE_TYPES.DARK:
		sprite.texture = DARK_BRICK


func got_grabbed() -> void:
	if !player: return
	based = result.instantiate() as Node2D
	player.add_child(based)
	based.position.y += 24
	for i in get_groups():
		based.add_to_group(i)
	player.suit.extra_vars.holding = based
	Audio.play_sound(player.suit.grab_sound_grab, player, false)
	
	queue_free()


func got_side_grabbed() -> void:
	if !player: return
	based = result.instantiate() as Node2D
	player.add_child(based)
	based.z_index = 1
	for i in get_groups():
		based.add_to_group(i)
	player.suit.extra_vars.holding = based
	Audio.play_sound(player.suit.grab_sound_grab, player, false)
	
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player && &"suit" in player && &"crutch" in player.suit.extra_vars:
		player.suit.extra_vars.crutch = false
