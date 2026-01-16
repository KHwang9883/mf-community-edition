extends "res://engine/objects/enemies/cheeps/cheep.gd"

@onready var body: Area2D = $Body
var killed: bool = false

func _physics_process(delta: float) -> void:
	super(delta)
	if killed: return
	
	var player = Thunder._current_player
	if !player: return
	if body.overlaps_body(player):
		collect(player)

func collect(player: Player) -> void:
	if player.is_starman(): return
	player.die()
	killed = true
	
	enemy_attacked.killing_sound_succeeded = null
	enemy_attacked.got_killed(&"boomerang", [&"no_score"])

func kill_enemy() -> void:
	enemy_attacked.got_killed(&"boomerang")

func activate() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	show()
