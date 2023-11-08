extends Control

@export var p1_texture : TextureRect
@export var p2_texture : TextureRect
@export var p1_name : Label
@export var p2_name : Label

var finish_loading : bool = false

signal start_game()

func _ready():
	set_process(false)
	start_game.connect(GameManager.on_start_game)
	var player1_data : PlayerData = GameManager.current_players_data["1"]
	var player2_data : PlayerData = GameManager.current_players_data["2"]
	p1_texture.texture = player1_data.player_in_game_texture
	p2_texture.texture = player2_data.player_in_game_texture
	p1_name.text = player1_data.player_name
	p2_name.text = player2_data.player_name
	pass

func _process(delta):
	if finish_loading: return
	$LoadingBar.value = lerp($LoadingBar.value, $LoadingBar.value + randf_range(0,50), delta)
	if $LoadingBar.value >= $LoadingBar.max_value:
		finish_loading = true
		start_game.emit()
		set_process(false)
	pass

func _on_animation_player_animation_finished(anim_name):
	set_process(true)
	$AnimationPlayer.play("loading")
	pass # Replace with function body.
