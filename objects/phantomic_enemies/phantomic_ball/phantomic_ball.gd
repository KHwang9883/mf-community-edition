extends Projectile

@onready var light: PointLight2D = $Light


func _physics_process(delta: float) -> void:
	super(delta)
	light.global_rotation = velocity.angle()
