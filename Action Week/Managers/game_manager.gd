extends Node

var players_victories : Dictionary = {
	"1":0,
	"2":0
}

var players_data : Array[PlayerData]

var current_players_data : Dictionary

signal victories_update(players)
signal reset_game()
signal start_special()
signal start_round()
signal end_round(round_winner)
signal end_game(winner)

var players : Array

var round_count : int = 0

var winner : PlayerData 

func _ready():
	players_data.append(load("res://Objects/Players/FedeData.tres"))
	players_data.append(load("res://Objects/Players/SantiData.tres"))
	players_data.append(load("res://Objects/Players/DaniData.tres"))
	players_data.append(load("res://Objects/Players/EmiData.tres"))
	pass

func resolve_victory(defeat_id : int):
	var winner_id = "1" if defeat_id == 2 else "2"
	add_victory(winner_id)
	pass

func add_victory(winner_id : String):
	players_victories[winner_id] += 1
	victories_update.emit(players_victories)
	end_round.emit(players[1] if winner_id == str(players[1].id) else players[0])
	pass

func add_player(player):
	players.append(player)
	pass

func check_round_timer_winner():
	var winner : Dummy = players[0]
	if players[0].hp < players[1].hp:
		winner = players[1]
		add_victory(str(winner.id))
	elif players[0].hp == players[1].hp:
		add_victory(str(players[0].id))
		add_victory(str(players[1].id))
	pass

func on_end_game():
	winner = players[0].player_data
	if players[0].is_dead:
		winner = players[1].player_data
	end_game.emit(winner)
	await get_tree().create_timer(5).timeout
	round_count = 0
	players_victories["1"] = 0
	players_victories["2"] = 0
	players.clear()
	get_tree().change_scene_to_file("res://Scenes/victory_screen.tscn")
	pass

func on_back_to_select():
	get_tree().change_scene_to_file("res://Scenes/player_selector_scene.tscn")
	pass

func reset_game_state():
	reset_game.emit()
	pass

func init_special():
	start_special.emit()
	Engine.time_scale = 0
	pass

func on_player_selected(controller_id : int, idx : int):
	current_players_data[str(controller_id)] = players_data[idx]
	pass

func on_start_game():
	winner = null
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/game_scene.tscn")
	pass

func on_start_loading():
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/loading_scene.tscn")
	pass

func on_special_selected(controller_id, special):
	current_players_data[str(controller_id)].player_special = special
	pass

func set_round_count(count : int):
	round_count = count
	pass

func start_round_game():
	start_round.emit()
	pass
