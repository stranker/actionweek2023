extends Resource

class_name PlayerData

@export var player_name : String
@export var player_in_game_texture : Texture
@export var player_portrait_texture : Texture
@export var player_special : PackedScene
@export var player_skin : Texture
@export var player_winner_speech : String


func _to_string():
	return "PlayerData(" + player_name + ")"
