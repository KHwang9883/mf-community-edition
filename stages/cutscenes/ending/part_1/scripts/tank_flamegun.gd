extends Area2D

@onready var kak_ogur_4_ik = $KakOgur4ik
@onready var eba = $Eba

const EXPLOSION_TANK = preload("res://stages/cutscenes/ending/part_1/scripts/explosion_tank.tscn")

func _ready():
	z_index = 0
	area_entered.connect(func(area):
		if eba.visible: return
		if area.is_in_group("cam_manager"):
			deploy()
	)

var speed: Vector2 = Vector2.ZERO

func deploy():
	z_index = 4
	speed = Vector2(-3, -7)
	Audio.play_sound(preload("res://engine/objects/bumping_blocks/_sounds/break.wav"), self)
	
	var expl = EXPLOSION_TANK.instantiate()
	expl.position = global_position
	expl.reset_physics_interpolation()
	Scenes.current_scene.add_child(expl)
	
	kak_ogur_4_ik.visible = false
	eba.visible = true


func _physics_process(delta):
	if speed == Vector2.ZERO: return
	speed.y += delta * 35
	position += speed * delta * 50
	rotation += delta * 12 * sign(speed.x)
	
	if position.y > 800: queue_free()
