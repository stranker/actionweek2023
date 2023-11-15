extends Node2D

@export var round_time : float = 99
@export var start_round_time : float = 5
@export var intro_animation : AnimationPlayer

signal end_round(player_id)
signal time_left(time)
signal round_timer_end()
signal reset_game_state()
signal end_game()

var rounds : int = 1

func _ready():
	$RoundTimer.wait_time = round_time
	GameManager.victories_update.connect(_end_round)
	round_timer_end.connect(GameManager.check_round_timer_winner)
	reset_game_state.connect(GameManager.reset_game_state)
	end_game.connect(GameManager.on_end_game)
	intro_animation.play("init")
	pass

func _process(delta):
	if not $RoundTimer.is_stopped():
		time_left.emit($RoundTimer.time_left)
	pass

func _end_round(players_victories : Dictionary):
	Engine.time_scale = 0.15
	await get_tree().create_timer(4, true, false, true)
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", 1, 2).set_trans(Tween.TRANS_EXPO)
	tween.play()
	await tween.finished
	print_debug("Rounds:",rounds, " - GM.RoundCount", GameManager.round_count)
	if rounds == GameManager.round_count:
		end_game.emit()
		$RoundTimer.stop()
	else:
		rounds += 1
		reset_game_state.emit()
		intro_animation.play("init")
	pass

func _on_round_timer_timeout():
	round_timer_end.emit()
	pass # Replace with function body.

func start_round():
	$RoundTimer.start()
	GameManager.start_round_game()
	pass
