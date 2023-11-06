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

var players : Array

func _ready():
	players_data.append(load("res://Objects/Players/FedeData.tres"))
	players_data.append(load("res://Objects/Players/SantiData.tres"))
	players_data.append(load("res://Objects/Players/DaniData.tres"))
	players_data.append(load("res://Objects/Players/EmiData.tres"))
	pass

func add_victory(winner_id : int):
	players_victories[str(winner_id)] += 1
	victories_update.emit(players_victories)
	pass

func add_player(player):
	players.append(player)
	pass

func check_round_timer_winner():
	var winner : Dummy = players[0]
	if players[0].hp < players[1].hp:
		winner = players[1]
		add_victory(winner.id)
	elif players[0].hp == players[1].hp:
		add_victory(players[0].id)
		add_victory(players[1].id)
	pass

func reset_game_state():
	reset_game.emit()
	pass

func init_special():
	start_special.emit()
	pass

func on_player_selected(controller_id, data: PlayerData):
	current_players_data[str(controller_id)] = data
	pass

func on_start_game():
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/game_scene.tscn")
	pass
