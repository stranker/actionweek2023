extends CanvasLayer

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
