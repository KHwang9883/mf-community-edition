extends GravityBody2D

signal health_changed(to: int)

const HUD: PackedScene = preload("./big_cheep_hud.tscn")
const CHEEP_GREEN = preload("res://engine/objects/enemies/cheeps/cheep_green.tscn")

@export_category("Bowser")
@export var health: int = 5:
	set(to):
		health = to
		(func() -> void: health_changed.emit(health)).call_deferred()
@export var attack_interval: float = 1.0
@export var attack_speed: Vector2 = Vector2(187.5, 0)
@export var death_speed: float = 175
@export_subgroup("Sounds")
@export var launch_sound: AudioStream = preload("res://engine/objects/enemies/lakitus/sounds/lakitu_myu.ogg")
@export var falling_sound: AudioStream = preload("res://engine/objects/bosses/bowser/sounds/bowser_fall.wav")
@export_group("HUD")
@export var y_offset: int = 0

var active: bool
var moving: bool
var attack_timer: float
var died: bool

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var enemy_attacked: Node = $Body/EnemyAttacked
@onready var launch_pos: Marker2D = $LaunchPos
var hud: CanvasLayer

func activate() -> void:
	active = true
	hud = HUD.instantiate()
	hud.bowser = self
	hud.y_offset = y_offset
	health_changed.connect(hud.life_changed)
	add_sibling.call_deferred(hud)
	health = health


func _physics_process(delta: float) -> void:
	if !active: return
	
	if attack_timer < 1.0:
		attack_timer += delta
	elif health > 0:
		attack_timer = 0
		Audio.play_sound(launch_sound, self, false)
		var pl :Player = Thunder._current_player
		var cheep = CHEEP_GREEN.instantiate()
		cheep.position = launch_pos.global_position
		cheep.look_at_player = false
		var angle: float = PI
		if pl:
			angle = launch_pos.global_position.angle_to_point(pl.global_position)
			angle = snappedf(angle, PI/16)
			
		cheep.speed = attack_speed.rotated(angle)
		cheep.is_spawned = true
		cheep.turn_y_enabled = false
		Scenes.current_scene.add_child(cheep)
		cheep.interval.paused = true
		cheep.visiblity.rect = cheep.visiblity.new_rect
		Thunder.reorder_on_top_of(cheep, self)
	
	if moving:
		motion_process(delta)


func hurt(_external_damage_source: bool = false) -> void:
	if died: return
	
	if health > 0:
		health -= 1
	if health <= 0:
		die()


func die() -> void:
	enemy_attacked.killing_sound_succeeded = null
	died = true
	var _sfx2 = CharacterManager.get_sound_replace(falling_sound, falling_sound, "bowser_fall", false)
	Audio.play_sound(_sfx2, self, false)
	await get_tree().create_timer(1.0, false, true, false).timeout
	var tw = create_tween()
	tw.tween_property(self, "speed:x", -death_speed, 0.5)
	moving = true
	


func _on_forcer_collected() -> void:
	Thunder.add_lives(1)
	var _sfx = CharacterManager.get_sound_replace(Data.LIFE_SOUND, Data.LIFE_SOUND, "1up", false)
	Audio.play_1d_sound(_sfx, false)
