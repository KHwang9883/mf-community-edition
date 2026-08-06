extends Sprite2D

@onready var head: Sprite2D = $Head
@onready var body: Sprite2D = $Body
@onready var l_arm: Sprite2D = $LArm
@onready var r_arm: Sprite2D = $RArm
@onready var l_leg: Sprite2D = $LLeg
@onready var r_leg: Sprite2D = $RLeg
@onready var parts = [head, body, l_arm, r_arm, l_leg, r_leg]

var INIT_SPEEDS = [
	Vector2(0, -44 * 6.25),
	Vector2(0, -24 * 6.25),
	Vector2(0, -24 * 6.25).rotated(deg_to_rad(-22.5)),
	Vector2(0, -24 * 6.25).rotated(deg_to_rad(22.5)),
	Vector2(0, -8 * 6.25).rotated(deg_to_rad(-22.5)),
	Vector2(0, -8 * 6.25).rotated(deg_to_rad(22.5)),
]

var speeds = []

func _ready() -> void:
	speeds.resize(INIT_SPEEDS.size())
	speeds.fill(Vector2.ZERO)

func switch_to_fett() -> void:
	head.region_rect = Rect2(31, 0, 31, 30)
	body.region_rect = Rect2(31, 46, 33, 18)

func _physics_process(delta: float) -> void:
	head.rotation_degrees += delta * 720
	body.rotation_degrees -= delta * 720
	l_arm.rotation_degrees -= delta * 720
	r_arm.rotation_degrees += delta * 720
	l_leg.rotation_degrees -= delta * 720
	r_leg.rotation_degrees += delta * 720
	for i in parts.size():
		parts[i].position += INIT_SPEEDS[i] * delta
