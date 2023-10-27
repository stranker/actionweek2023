extends CanvasLayer

func _ready():
	$Main/LeftUltiText.hide()
	$Main/RightUltiText.hide()
	pass

func _on_dummy_hp_update(hp):
	$Main/HealthBar1.value = hp
	pass # Replace with function body.


func _on_dummy_2_hp_update(hp):
	$Main/HealthBar2.value = hp
	pass # Replace with function body.


func _on_dummy_guard_stamina_update(stamina):
	$Main/GuardStaminaBar1.value = stamina
	pass # Replace with function body.


func _on_dummy_2_guard_stamina_update(stamina):
	$Main/GuardStaminaBar2.value = stamina
	pass # Replace with function body.


func _on_game_scene_end_round(player_id):
	if player_id == 1:
		$Main/Anim.play("left_ulti")
	pass # Replace with function body.


func _on_dummy_2_special_start(special_name):
	$Main/RightUltiText.show()
	$Main/RightUltiText.text = "[rainbow freq=2.0 sat=0.8 val=0.8][wave amp=50.0 freq=5.0 connected=1][shake rate=30.0 level=20 connected=1]" + special_name + "[/shake][/wave][/rainbow]"
	pass # Replace with function body.


func _on_dummy_special_start(special_name):
	$Main/LeftUltiText.show()
	$Main/Anim.play("left_ulti")
	$Main/LeftUltiText.text = "[rainbow freq=2.0 sat=0.8 val=0.8][wave amp=50.0 freq=5.0 connected=1][shake rate=30.0 level=20 connected=1]" + special_name + "[/shake][/wave][/rainbow]"
	pass # Replace with function body.


func _on_dummy_special_end():
	$Main/LeftUltiText.hide()
	pass # Replace with function body.


func _on_dummy_2_special_end():
	$Main/RightUltiText.hide()
	pass # Replace with function body.
