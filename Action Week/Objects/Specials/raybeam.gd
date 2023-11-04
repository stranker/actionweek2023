extends Special

var ref_player : Dummy

func init(player : Dummy, pos : Vector2, facing_direction : Vector2, attack_layer : int, enemy_layer : int):
	super.init(player, pos, facing_direction, attack_layer, enemy_layer)
	global_position = pos
	scale.x = facing_direction.x
	set_collision_layer_value(attack_layer, true)
	set_collision_mask_value(enemy_layer, true)
	ref_player = player
	GameManager.start_special.connect(_on_start_special)
	pass

func _on_start_special():
	$AnimationPlayer.play("start")
	pass

func _on_body_entered(body):
	var dummy : Dummy = body as Dummy
	if dummy.is_dead or ref_player == null: return
	dummy.hit(damage, body.global_position)
	ref_player.add_connected_hit()
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(0.15).timeout
	$CollisionShape2D.set_deferred("disabled", false)
	pass # Replace with function body.


func _on_animation_player_animation_finished(anim_name):
	stop()
	pass # Replace with function body.

func stop():
	$AnimationPlayer.stop()
	finish.emit()
	queue_free()
	pass
