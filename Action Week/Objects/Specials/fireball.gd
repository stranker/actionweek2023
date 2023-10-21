extends Area2D

var direction : Vector2 = Vector2.RIGHT

func _physics_process(delta):
	translate(direction * 1200 * delta)
	pass

func init(pos : Vector2, dir : Vector2, layer : int, mask : int):
	direction = dir
	global_position = pos
	pass
