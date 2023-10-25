extends Node2D

signal end_round(player_id)

func _on_dummy_2_dead():
	_end_round()
	end_round.emit(1)
	pass # Replace with function body.


func _on_dummy_dead():
	_end_round()
	end_round.emit(2)
	pass # Replace with function body.

func _end_round():
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", 0.1, 0.2).set_trans(Tween.TRANS_EXPO)
	tween.play()
	await tween.finished
	tween.stop()
	tween.tween_property(Engine, "time_scale", 1, 0.2).set_trans(Tween.TRANS_EXPO)
	tween.play()
	await get_tree().create_timer(2).timeout
	get_tree().reload_current_scene()
	pass 
