extends Area2D

signal player_enter
signal player_exit

const BOO_CIRCLE = preload("res://engine/objects/enemies/boo/boo_circle_generator.tscn")
const SMOKE = preload("res://engine/objects/effects/smoke/smoke.tscn")
const BOO_2 = preload("res://engine/objects/enemies/boo/sounds/boo2.wav")

var player
var activated: bool

@onready var boos: Node2D = $Boos
@onready var sprite_2d: Sprite2D = $Sprite2D

func _physics_process(_delta: float) -> void:
	if !player: return
	if activated: return
	
	var input_y: int = int(Input.get_axis(player.control.up, player.control.down))
	
	if input_y < 0:
		activated = true
		Audio.play_sound(BOO_2, self)
		for i in range(2):
			var efect = SMOKE.instantiate()
			Scenes.current_scene.add_child(efect)
			efect.global_position.x = global_position.x
			efect.global_position.y = global_position.y - 16 - (32 * i)
		sprite_2d.visible = false
		
		var boo_circle = BOO_CIRCLE.instantiate()
		boos.add_child(boo_circle)
		#boo_circle.visible = false
		(func():
			for i in boo_circle.get_children():
				var enem = i.get_node(^"Body/EnemyAttacked")
				enem.stomping_enabled = false
				enem.killing_enabled = false
				i.amplitude = Vector2.ONE
				boo_circle.visible = true
				
				var tw: Tween = i.create_tween()
				tw.tween_property(
					i, ^"amplitude", Vector2(150, 150), 0.8
				).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				tw.tween_callback(func():
					enem.stomping_enabled = true
					enem.killing_enabled = true
				)
				tw.tween_property(
					i, ^"frequency", 1.0, 0.3
				)
				
		).call_deferred()


func _on_body_entered(body: Node2D) -> void:
	if Engine.is_editor_hint(): return
	if body == Thunder._current_player:
		player = body
		player_enter.emit()

func _on_body_exited(body: Node2D) -> void:
	if Engine.is_editor_hint(): return
	if body == Thunder._current_player:
		player = null
		player_exit.emit()
