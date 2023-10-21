extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_dummy_hp_update(hp):
	$Main/HealthBar1.value = hp
	pass # Replace with function body.


func _on_dummy_2_hp_update(hp):
	$Main/HealthBar2.value = hp
	pass # Replace with function body.
