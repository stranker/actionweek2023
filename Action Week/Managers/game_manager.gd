extends Node

var players_victories : Dictionary = {
	"1":0,
	"2":0
}

signal victories_update(players)
signal reset_game()

var players : Array

func add_victory(player_defeated_id : int):
	var win_player_id = 1 if player_defeated_id == 2 else 2
	players_victories[str(win_player_id)] += 1
	victories_update.emit(players_victories)
	pass

func add_player(player):
	players.append(player)
	pass

func check_round_timer_winner():
	var winner = players[0]
	var defeated = players[1]
	if players[0].hp < players[1].hp:
		winner = players[1]
		defeated = players[0]
	add_victory(defeated.id)
	pass

func reset_game_state():
	reset_game.emit()
	pass
