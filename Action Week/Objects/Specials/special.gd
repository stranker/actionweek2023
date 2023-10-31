extends Area2D

class_name Special

@export var damage : int = 10
@export var special_name : String = "Placeholder"

signal start(name)
signal finish()

func _on_start():
	start.emit(special_name)
	pass

func init(player : Dummy, pos : Vector2, facing_direction : Vector2, attack_layer : int, enemy_layer : int):
	_on_start()
	pass
