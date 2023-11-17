extends Area2D

class_name Special

@export var damage : int = 10
@export var special_name : String = "Placeholder"
@export var special_anim_name : String = "Placeholder"
var ref_player : Dummy

signal start(name)
signal finish()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	pass

func _on_start():
	start.emit(special_name)
	GameManager.start_special.connect(_on_start_special)
	pass

func init(player : Dummy, pos : Vector2, facing_direction : Vector2, attack_layer : int, enemy_layer : int):
	_on_start()
	global_position = pos
	scale.x = facing_direction.x
	set_collision_layer_value(attack_layer, true)
	set_collision_mask_value(enemy_layer, true)
	ref_player = player
	pass

func _on_start_special():
	pass
