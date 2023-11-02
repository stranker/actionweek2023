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
	Engine.time_scale = 0.1
	await get_tree().create_timer(4, true, false, true)
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", 1, 2).set_trans(Tween.TRANS_EXPO)
	tween.play()
	await tween.finished
	get_tree().reload_current_scene()
	pass 
