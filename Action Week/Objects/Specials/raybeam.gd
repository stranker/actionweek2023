extends Area2D

signal start()
signal finish()

func init(pos : Vector2, facing_direction : Vector2, attack_layer : int, enemy_layer : int):
	global_position = pos
	scale.x = facing_direction.x
	set_collision_layer_value(attack_layer, true)
	set_collision_mask_value(enemy_layer, true)
	start.emit()
	pass

func _on_body_entered(body):
	print_debug(body)
	pass # Replace with function body.


func _on_animation_player_animation_finished(anim_name):
	stop()
	pass # Replace with function body.

func stop():
	$AnimationPlayer.stop()
	finish.emit()
	queue_free()
	pass
