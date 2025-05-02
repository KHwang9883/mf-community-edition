extends Node

var is_zero: bool = false
@onready var old_death_music
@onready var old_death_stop_music
@onready var old_wait_time

func _ready() -> void:
	await get_tree().physics_frame
	var pl: Player = $".."
	if Data.values.lives == 0 && pl.death_check_for_lives:
		is_zero = true
		old_death_music = pl.death_music_override
		old_death_stop_music = pl.death_stop_music
		old_wait_time = pl.death_wait_time
		pl.death_music_override = null
		pl.death_stop_music = true
		pl.death_wait_time = 3.5

func _physics_process(delta: float) -> void:
	if is_zero && Data.values.lives > 0:
		var pl: Player = $".."
		is_zero = false
		pl.death_music_override = old_death_music
		pl.death_stop_music = old_death_stop_music
		pl.death_wait_time = old_wait_time
