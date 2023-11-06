extends Special


func _on_start_special():
	super._on_start_special()
	$AnimationPlayer.play("start")
	$Sfx.play()
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
