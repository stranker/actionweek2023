extends CharacterBody2D

class_name Dummy

@export var SPEED : float = 300.0
@export var JUMP_VELOCITY = -400.0

@export var id : int = 0
@export var hp : int = 100
@export var enemy_player : Dummy

signal hp_update(hp)
signal guard_stamina_update(stamina)
signal dead()

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	GUARD,
	GRAB,
	SPECIAL,
	HIT,
	DEAD
}
@export var current_state : State = State.IDLE

var facing_direction : Vector2 = Vector2.RIGHT

@export var attack_collision : CollisionShape2D
@export var right_attack_area : Area2D
@export var left_attack_area : Area2D
@export var grab_area : Area2D

var can_attack : bool = true
var is_dead : bool = false
var can_recover_guard : bool = false

@export var player_layer : int
@export var attack_layer : int
@export var enemy_layer : int

@export var special_scene : PackedScene
@export var attack_distance : float = 200
var start_attack_distance : Vector2

var attack_combo : int = 1
@export var damage_per_combo : = 5
@export var guard_stamina : float = 50

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready(): #Start()
	set_collision_layer_value(player_layer, true )
	set_collision_mask_value(enemy_layer, true)
	right_attack_area.set_collision_layer_value(attack_layer, true)
	right_attack_area.set_collision_mask_value(enemy_layer, true)
	left_attack_area.set_collision_layer_value(attack_layer, true)
	left_attack_area.set_collision_mask_value(enemy_layer, true)
	set_state(State.IDLE)
	pass

func _process(delta): #Update()
	$Visible.scale.x = facing_direction.x
	_fsm()
	pass

func _fsm():
	match current_state:
		State.IDLE:
			if is_on_floor():
				check_grab_input()
				check_jump_input()
				if abs(velocity.x) > 0:
					set_state(State.RUN)
			else:
				if velocity.y > 0:
					set_state(State.FALL)
			check_attack_input()
			check_press_guard_input()
		State.RUN:
			if is_on_floor():
				if abs(velocity.x) < 0.1:
					set_state(State.IDLE)
				check_grab_input()
				check_jump_input()
			check_attack_input()
			check_press_guard_input()
		State.JUMP:
			check_attack_input()
			check_press_guard_input()
			if not is_on_floor() and velocity.y > 0:
				set_state(State.FALL)
		State.FALL:
			check_attack_input()
			check_press_guard_input()
			if is_on_floor() and velocity.y >= 0:
				if abs(velocity.x) > 0:
					set_state(State.RUN)
				else:
					set_state(State.IDLE)
		State.ATTACK:
			pass
		State.GUARD:
			check_release_guard_input()
	pass

func check_attack_input():
	if Input.is_action_just_pressed("attack" + str(id)) and can_attack:
		set_state(State.ATTACK)
	pass

func check_jump_input():
	if Input.is_action_just_pressed("jump" + str(id)) and is_on_floor():
		set_state(State.JUMP)
	pass

func check_press_guard_input():
	if Input.is_action_just_pressed("guard" + str(id)) and guard_stamina > 0:
		set_state(State.GUARD)
	pass

func check_release_guard_input():
	if Input.is_action_just_released("guard" + str(id)) or guard_stamina <= 0:
		set_state(State.IDLE)
		$RecoverGuardTimer.start()
	pass

func check_grab_input():
	if Input.is_action_just_pressed("grab" + str(id)):
		set_state(State.GRAB)
	pass

func set_state(new_state : State):
	if current_state == new_state: return
	$AnimationPlayer.play("RESET")
	current_state = new_state
	$Debug/Label.text = "STATE:" + State.keys()[current_state]
	match current_state:
		State.IDLE:
			_idle_state()
		State.RUN:
			_run_state()
		State.ATTACK:
			_attack_state()
		State.JUMP:
			_jump_state()
		State.FALL:
			_fall_state()
		State.SPECIAL:
			_special_state()
		State.DEAD:
			_dead_state()
		State.GUARD:
			_guard_state()
		State.GRAB:
			_grab_state()
		State.HIT:
			_hit_state()
	pass

func _idle_state():
	$AnimationPlayer.play("idle")
	reset_attack()
	pass

func _run_state():
	$AnimationPlayer.play("run")
	pass

func _attack_state():
	attack()
	pass

func _jump_state():
	$AnimationPlayer.play("jump")
	velocity.y = JUMP_VELOCITY
	pass

func _fall_state():
	$AnimationPlayer.play("fall")
	pass

func _special_state():
	velocity.y = 0
	var special = special_scene.instantiate()
	get_tree().root.add_child(special)
	special.init(global_position, facing_direction, attack_layer, enemy_layer)
	pass

func _dead_state():
	dead.emit()
	$AnimationPlayer.play("dead")
	pass

func _guard_state():
	can_recover_guard = false
	$AnimationPlayer.play("guard")
	pass

func _hit_state():
	if hp <= 0:
		is_dead = true
		set_state(State.DEAD)
	else:
		$AnimationPlayer.play("hit")
	pass

func _grab_state():
	$AnimationPlayer.play("grab")
	velocity.x = 0
	pass

func _physics_process(delta): #FixedUpdate()
	if can_attack and not is_dead:
		if enemy_player.global_position.x < global_position.x:
			facing_direction = Vector2.LEFT
		else:
			facing_direction = Vector2.RIGHT
	if can_recover_guard:
		guard_stamina += delta * 10
		if guard_stamina >= 50:
			guard_stamina = 50
			can_recover_guard = false
		guard_stamina_update.emit(guard_stamina)
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	match current_state:
		State.IDLE:
			_movement(delta)
		State.RUN:
			_movement(delta)
		State.ATTACK:
			_movement_attack(delta)
		State.JUMP:
			_movement(delta)
		State.FALL:
			_movement(delta)
		State.GUARD:
			velocity.x = 0
	move_and_slide()
	pass

func _movement(delta):
	var direction = Input.get_axis("move_left" + str(id), "move_right" + str(id))
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	pass

func _movement_attack(delta):
	velocity.x = 0
	pass

func attack():
	if not can_attack: return
	can_attack = false
	if not $AttackComboTimer.is_stopped():
		attack_combo += 1
		if attack_combo > 3:
			attack_combo = 1
	$AttackComboTimer.start()
	$AnimationPlayer.play("attack" + str(attack_combo))
	start_attack_distance = global_position
	pass

func take_damage(damage : int):
	if is_dead: return
	hp -= damage
	hp_update.emit(hp)
	set_state(State.HIT)
	pass

func hit(damage : int):
	if current_state == State.GUARD:
		guard_stamina -= damage
		guard_stamina = clamp(guard_stamina, 0, 50)
		guard_stamina_update.emit(guard_stamina)
	else:
		take_damage(damage)
	pass

func reset_attack():
	can_attack = true
	set_state(State.IDLE)
	pass

func _on_right_attack_area_body_entered(body):
	var dummy : Dummy = body as Dummy
	dummy.take_damage(damage_per_combo * attack_combo)
	pass # Replace with function body.


func _on_left_attack_area_body_entered(body):
	var dummy : Dummy = body as Dummy
	dummy.take_damage(damage_per_combo * attack_combo)
	pass # Replace with function body.


func _on_attack_combo_timer_timeout():
	attack_combo = 1
	pass # Replace with function body.


func _on_recover_guard_timer_timeout():
	can_recover_guard = true
	pass # Replace with function body.


func _on_grab_area_body_entered(body):
	var dummy : Dummy = body as Dummy
	dummy.grab()
	pass # Replace with function body.

func grab():
	can_attack = false
	take_damage(20)
	pass
