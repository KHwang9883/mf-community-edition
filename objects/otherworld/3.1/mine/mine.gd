extends Powerup

const EXPLOSION = preload("res://objects/volcano/bob_omb/explosion/explosion.tscn")
const explosion_effect = preload("res://objects/volcano/bob_omb/explosion/explosion_effect.tscn")
const BOMB_OMB = preload("res://objects/otherworld/3.1/mine/bomb-omb.wav")

@onready var sprite: Sprite2D = $Sprite2D
@onready var attack: ShapeCast2D = $Attack
@onready var enemy_attacked: Node = $Body/EnemyAttacked

@export var dead_counter: float = 50
@export var is_scripted: bool = false
var scr_tilemap: TileMapLayer

func collect() -> void:
	if appear_distance > 24: return
	var player = Thunder._current_player
	
	if player.is_invincible(): return
	player.hurt()


func _ready() -> void:
	if !is_scripted:
		super()
		return
	
	appear_distance = 0
	appear_visible = 0
	scr_tilemap = $"../../Control2/TileMapLayer"
	var _index: int = get_index()
	if _index < 6:
		dead_counter = 59 + (_index * 11)
		enemy_attacked.killing_enabled = false
		return
	dead_counter = 59 + ((_index - 3) * 22)


func _physics_process(delta: float) -> void:
	if is_scripted && !is_visible_in_tree(): return
	super(delta)
	
	if appear_distance > 0: return
	if dead_counter <= 50:
		attack.enabled = true
	
	dead_counter -= delta * 50
	if dead_counter > 50:
		return
	sprite.position = Vector2(randi_range(-2, 2), randi_range(-2, 2))
	
	if int(dead_counter) % 10 == 0:
		Audio.play_sound(BOMB_OMB, self, false, {volume = -4})
	
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
		if is_scripted && scr_tilemap:
			var local_pos = scr_tilemap.local_to_map(scr_tilemap.to_local(global_position))
			scr_tilemap.set_cell(local_pos, 0, Vector2i(5, 0))
		if Thunder.view.is_getting_closer(self, 256):
			Thunder._current_camera.shock_smooth(6, 10)
		queue_free()
