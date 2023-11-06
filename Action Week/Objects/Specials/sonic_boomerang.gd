extends Special

func init(player : Dummy, pos : Vector2, facing_direction : Vector2, attack_layer : int, enemy_layer : int):
	super.init(player, pos, facing_direction, attack_layer, enemy_layer)
	pass

func _on_start_special():
	super._on_start_special()
	$AnimationPlayer.play("throw")
	pass

func _on_animation_player_animation_finished(anim_name):
	$AnimationPlayer.stop()
	finish.emit()
	queue_free()
	pass # Replace with function body.

func _on_body_entered(body):
	var dummy : Dummy = body as Dummy
	if dummy.is_dead or ref_player == null: return
	dummy.hit(damage, body.global_position)
	ref_player.add_connected_hit()
	pass # Replace with function body.
