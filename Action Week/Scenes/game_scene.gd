extends Node2D

@export var round_time : float = 99
signal end_round(player_id)
signal time_left(time)

func _ready():
	$RoundTimer.wait_time = round_time
	$RoundTimer.start()
	pass

func _process(delta):
	if not $RoundTimer.is_stopped():
		time_left.emit($RoundTimer.time_left)
	pass

func _on_dummy_2_dead():
	_end_round()
	end_round.emit(1)
	pass # Replace with function body.


func _on_dummy_dead():
	_end_round()
	end_round.emit(2)
	pass # Replace with function body.

func _end_round():
	Engine.time_scale = 0.15
	await get_tree().create_timer(4, true, false, true)
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", 1, 2).set_trans(Tween.TRANS_EXPO)
	tween.play()
	await tween.finished
	get_tree().reload_current_scene()
	pass

func _on_round_timer_timeout():
	_end_round()
	pass # Replace with function body.
