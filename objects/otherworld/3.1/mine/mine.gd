extends Powerup

const EXPLOSION = preload("res://objects/volcano/bob_omb/explosion/explosion.tscn")
const explosion_effect = preload("res://engine/objects/effects/explosion/explosion.tscn")
const BOMB_OMB = preload("res://objects/otherworld/3.1/mine/bomb-omb.wav")

@onready var sprite: Sprite2D = $Sprite2D
@onready var attack: ShapeCast2D = $Attack

var dead_counter: float = 50

func collect() -> void:
	if appear_distance > 24: return
	var player = Thunder._current_player
	
	if player.is_invincible(): return
	player.hurt()
	


func _physics_process(delta: float) -> void:
	super(delta)
	
	if appear_distance > 0: return
	if dead_counter == 50:
		attack.enabled = true
	
	dead_counter -= delta * 50
	sprite.position = Vector2(randi_range(-2, 2), randi_range(-2, 2))
	
	if int(dead_counter) % 10 == 0:
		Audio.play_sound(BOMB_OMB, self, false)
	
	if int(dead_counter) % 5 == 0:
		var _eff = explosion_effect.instantiate()
		_eff.scale = Vector2.ONE * 2
		_eff.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_eff.position = global_position + Vector2(randi_range(-20, 20), randi_range(-20, 20))
		Scenes.current_scene.add_child(_eff)
		
	
	if dead_counter < 1.0:
		Audio.play_sound(BOMB_OMB, self, false)
		var expl = EXPLOSION.instantiate()
		expl.position = global_position
		expl.z_index = 5
		Scenes.current_scene.add_child(expl)
		queue_free()
