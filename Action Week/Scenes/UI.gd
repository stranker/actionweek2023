extends CanvasLayer

func _ready():
	$BigImpactRect.hide()
	var players : Array = get_tree().get_nodes_in_group("Player")
	for player in players:
		player.big_impact.connect(_show_big_impact)
	GameManager.victories_update.connect(_on_victories_updated)
	pass

func _on_victories_updated(players_victories : Dictionary):
	$Main/Clock/Score1.text = str(players_victories["1"])
	$Main/Clock/Score2.text = str(players_victories["2"])
	pass

func _show_big_impact():
	$BigImpactRect.show()
	await get_tree().create_timer(0.05).timeout
	$BigImpactRect.hide()
	Engine.time_scale = 0
	await get_tree().create_timer(0.12, true, false, true).timeout
	Engine.time_scale = 1
	pass


func _on_game_scene_time_left(time):
	$Main/Clock/Time.text = str(int(time))
	pass # Replace with function body.


func _on_game_scene_end_round(player_id):
	pass # Replace with function body.
