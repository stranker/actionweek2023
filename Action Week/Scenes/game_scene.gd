extends Node2D


func _on_dummy_2_dead():
	_end_round()
	pass # Replace with function body.


func _on_dummy_dead():
	_end_round()
	pass # Replace with function body.

func _end_round():
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", 0.1, 0.2).set_trans(Tween.TRANS_EXPO)
	tween.play()
	await tween.finished
	tween.stop()
	tween.tween_property(Engine, "time_scale", 1, 0.2).set_trans(Tween.TRANS_EXPO)
	tween.play()
	pass 
