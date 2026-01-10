extends GeneralMovementBody2D

const BREAK = preload("res://engine/objects/bumping_blocks/_sounds/break.wav")
@export var GOOMBA_VOLCANO_DEAD = preload("res://objects/volcano/goomba_volcano/goomba_volcano_dead.tscn")

@export var hp: int = 1
@export var score: int = 100

@onready var enemy_attacked: Node = $Body/EnemyAttacked


func stomp(attacker: StringName = &"") -> void:
	if hp > 0 && (attacker == &"fireball" || !attacker):
		hp -= 1
		sprite_node.animation = "damaged"
		_shake()
	else:
		enemy_attacked.killing_can_combo = true
		enemy_attacked.stomping_creation = InstanceNode2D.new()
		enemy_attacked.stomping_creation.creation_nodepack = GOOMBA_VOLCANO_DEAD
		enemy_attacked.stomping_sound = BREAK
		enemy_attacked.stomping_scores = score
		
		enemy_attacked.killing_creation = InstanceNode2D.new()
		enemy_attacked.killing_creation.creation_nodepack = GOOMBA_VOLCANO_DEAD
		enemy_attacked.killing_sound_succeeded = BREAK
		enemy_attacked.killing_scores = score
		
		queue_free()


func _shake() -> void:
	var spr = get_node(sprite) as AnimatedSprite2D
	var tw = create_tween()
	tw.tween_property(spr, "position:x", 1, 0.04)
	tw.tween_property(spr, "position:x", -1, 0.04)
	tw.set_loops(5)
