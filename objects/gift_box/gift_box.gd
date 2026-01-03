extends GeneralMovementBody2D

@export var creation: InstanceNode2D
@export var hp: int = 3
@export var break_sound = preload("res://objects/gift_box/sounds/present_break.wav")
@export var score: int = 100

@onready var enemy_attacked: Node = $Body/EnemyAttacked

func _ready() -> void:
	super()
	
	var spr = get_node(sprite) as AnimatedSprite2D
	spr.frame = randi_range(0, 11)


func stomp() -> void:
	if hp > 0:
		hp -= 1
		_shake()
	else:
		if creation.has_method(&"prepare"):
			enemy_attacked.stomping_creation = creation.prepare()
		else:
			enemy_attacked.stomping_creation = creation
		enemy_attacked.stomping_sound = break_sound
		enemy_attacked.stomping_scores = score
		queue_free()


func _shake() -> void:
	var spr = get_node(sprite) as AnimatedSprite2D
	var tw = create_tween()
	tw.tween_property(spr, "position:x", 1, 0.04)
	tw.tween_property(spr, "position:x", -1, 0.04)
	tw.set_loops(5)
