extends GeneralMovementBody2D

const STOMPED_CREATION = preload("res://objects/human_lab_2/ramireys/mutant_clone/stomped_resource.tres")
const KICK_A = preload("res://objects/human_lab_2/ramireys/mutant_clone/sfx/kick_a.ogg")
const KICK_B = preload("res://objects/human_lab_2/ramireys/mutant_clone/sfx/kick_b.ogg")
const STOMP_A = preload("res://objects/human_lab_2/ramireys/mutant_clone/sfx/stomp_a.ogg")
const STOMP_B = preload("res://objects/human_lab_2/ramireys/mutant_clone/sfx/stomp_b.ogg")

var stomped: int

@onready var enemy_attacked: Node = $Body/EnemyAttacked

func _on_enemy_attacked_stomped_succeeded() -> void:
	var pl: Player = Thunder._current_player
	if !pl: return
	if stomped:
		var vars: Dictionary = {
			enemy_attacked = enemy_attacked,
		}
		NodeCreator.prepare_ins_2d(STOMPED_CREATION, self).execute_instance_script(vars).create_2d()
		if stomped == 2:
			Audio.play_sound(STOMP_A, self, false)
		else:
			Audio.play_sound(STOMP_B, self, false)
		queue_free()
		return
	
	if pl.global_position.x < global_position.x:
		sprite_node.animation = "stomp_l"
		stomped = 1
		Audio.play_sound(STOMP_A, self, false)
		speed.x *= 2
		enemy_attacked.killing_sound_succeeded = KICK_B
	else:
		sprite_node.animation = "stomp_r"
		stomped = 2
		Audio.play_sound(STOMP_B, self, false)
		speed.x *= 2
		enemy_attacked.killing_sound_succeeded = KICK_A
