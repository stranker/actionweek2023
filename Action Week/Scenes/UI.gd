extends CanvasLayer

func _ready():
	$BigImpactRect.hide()
	var players : Array = get_tree().get_nodes_in_group("Player")
	for player in players:
		player.big_impact.connect(_show_big_impact)
	pass

func _show_big_impact():
	$BigImpactRect.show()
	await get_tree().create_timer(0.05).timeout
	$BigImpactRect.hide()
	Engine.time_scale = 0
	await get_tree().create_timer(0.2, true, false, true).timeout
	Engine.time_scale = 1
	pass
