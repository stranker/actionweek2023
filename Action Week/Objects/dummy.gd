extends CharacterBody2D

class_name Dummy

@export var SPEED : float = 300.0
@export var JUMP_VELOCITY = -400.0

@export var id : int = 0
@export var hp : int = 100
@export var enemy_player : Dummy
@export var debug_enabled : bool = false

var hurt_particles_scene = preload("res://Objects/Particles/hurt_particles.tscn")
var dust_particles_scene = preload("res://Objects/Particles/dust_particles.tscn")
var guard_particles_scene = preload("res://Objects/Particles/guard_particles.tscn")

signal hp_update(hp)
signal guard_stamina_update(stamina)
signal dead()
signal special_start(special_name)
signal special_end()
signal connect_hit(hits)
signal end_connect_hit()
signal big_impact()
signal hit_floor()

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	GUARD,
	GRAB,
	GRABBED,
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

var can_attack : bool = false
var can_move: bool = true
var is_dead : bool = false
var can_recover_guard : bool = false
var grab_success : bool = false
var can_be_attacked : bool = true

@export var player_layer : int
@export var attack_layer : int
@export var enemy_layer : int

@export var special_scene : PackedScene
@export var attack_distance : float = 200
var start_attack_distance : Vector2

var attack_combo : int = 1
@export var damage_per_combo : = 5
@export var guard_stamina : float = 50
var connected_hit = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready(): #Start()
	set_collision_layer_value(player_layer, true )
	set_collision_mask_value(enemy_layer, true)
	right_attack_area.set_collision_layer_value(attack_layer, true)
	right_attack_area.set_collision_mask_value(enemy_layer, true)
	left_attack_area.set_collision_layer_value(attack_layer, true)
	left_attack_area.set_collision_mask_value(enemy_layer, true)
	grab_area.set_collision_layer_value(attack_layer, true)
	grab_area.set_collision_mask_value(enemy_layer, true)
	$Debug.visible = debug_enabled
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
			check_special_input()
		State.RUN:
			if is_on_floor():
				if abs(velocity.x) < 0.1:
					set_state(State.IDLE)
				check_grab_input()
				check_jump_input()
			check_attack_input()
			check_press_guard_input()
			check_special_input()
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
				_add_dust_particles()
				hit_floor.emit()
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

func check_special_input():
	if Input.is_action_just_pressed("special" + str(id)):
		set_state(State.SPECIAL)
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
		State.GRABBED:
			_grabbed_state()
		State.HIT:
			_hit_state()
	pass

func _idle_state():
	$AnimationPlayer.play("idle")
	reset_attack()
	velocity = Vector2.ZERO
	can_move = true
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
	$Jump.pitch_scale = randf_range(1.2,1.9)
	$Jump.play()
	pass

func _fall_state():
	$AnimationPlayer.play("fall")
	pass

func _special_state():
	var special : Special = special_scene.instantiate() as Special
	special.start.connect(on_special_start)
	special.finish.connect(on_special_finish)
	get_tree().root.add_child(special)
	special.init(self, global_position, facing_direction, attack_layer, enemy_layer)
	pass

func on_special_start(special_name : String):
	velocity = Vector2.ZERO
	can_move = false
	special_start.emit(special_name)
	pass

func on_special_finish():
	can_move = true
	set_state(State.IDLE)
	special_end.emit()
	pass

func _dead_state():
	dead.emit()
	$AnimationPlayer.play("dead")
	velocity = Vector2.ZERO
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

func _grabbed_state():
	can_attack = false
	can_move = false
	$AnimationPlayer.play("grabbed")
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
			_no_movement()
		State.JUMP:
			_movement(delta)
		State.FALL:
			_movement(delta)
		State.GRABBED:
			_movement_grabbed(delta)
		State.GUARD:
			_no_movement()
		State.SPECIAL:
			_no_movement()
	move_and_slide()
	pass

func _movement(delta):
	if not can_move: return
	var direction = Input.get_axis("move_left" + str(id), "move_right" + str(id))
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	pass

func _no_movement():
	velocity.x = 0
	pass

func _movement_grabbed(delta):
	velocity = -facing_direction * 800
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

func take_damage(damage : int, damage_pos : Vector2):
	if not can_be_attacked: return
	if is_dead: return
	hp -= damage
	hp_update.emit(hp)
	velocity.x = -facing_direction.x * 150
	set_state(State.HIT)
	_add_hurt_particles(damage_pos)
	pass

func _add_hurt_particles(damage_pos : Vector2):
	var hurt_particles : Node2D = hurt_particles_scene.instantiate()
	get_tree().root.add_child(hurt_particles)
	hurt_particles.global_position = damage_pos
	pass

func _add_dust_particles():
	var dust_particles : Node2D = dust_particles_scene.instantiate()
	get_tree().root.add_child(dust_particles)
	dust_particles.init($Visible/Skin/Body/LeftFoot.global_position)
	pass

func _add_guard_particles(pos : Vector2):
	var guard_particles = guard_particles_scene.instantiate()
	get_tree().root.add_child(guard_particles)
	guard_particles.init(facing_direction, global_position)
	pass

func hit(damage : int, damage_pos : Vector2):
	if not can_be_attacked: return false
	if current_state == State.GUARD:
		guard_stamina -= damage
		guard_stamina = clamp(guard_stamina, 0, 50)
		guard_stamina_update.emit(guard_stamina)
		_add_guard_particles(damage_pos)
		return false
	else:
		take_damage(damage, damage_pos)
		return true
	pass

func reset_attack():
	can_attack = true
	set_state(State.IDLE)
	pass

func _on_right_attack_area_body_entered(body):
	var dummy : Dummy = body as Dummy
	attack_player(dummy, $Visible/Skin/Body/RightHand.global_position)
	pass # Replace with function body.


func _on_left_attack_area_body_entered(body):
	var dummy : Dummy = body as Dummy
	attack_player(dummy, $Visible/Skin/Body/LeftHand.global_position)
	pass # Replace with function body.

func attack_player(player : Dummy, pos : Vector2):
	if player.is_dead: return
	var sucess_hit = player.hit(damage_per_combo * attack_combo, pos)
	if sucess_hit:
		add_connected_hit()
		if attack_combo == 3:
			big_impact.emit()
	pass

func add_connected_hit():
	connected_hit += 1
	connect_hit.emit(connected_hit)
	$ConnectedHitsTimer.start()
	pass

func _on_attack_combo_timer_timeout():
	attack_combo = 1
	pass # Replace with function body.


func _on_recover_guard_timer_timeout():
	can_recover_guard = true
	pass # Replace with function body.


func _on_grab_area_body_entered(body):
	var dummy : Dummy = body as Dummy
	dummy.grab()
	grab_success = true
	pass # Replace with function body.

func grab():
	if is_dead: return
	set_state(State.GRABBED)
	pass

func take_grab_damage():
	take_damage(20, global_position)
	_add_dust_particles()
	can_be_attacked = false
	$CanBeAttackedTimer.start()
	pass

func check_grab_success():
	if not grab_success:
		$AnimationPlayer.stop()
		set_state(State.IDLE)
	grab_success = false
	pass

func check_drag_end_state():
	if is_dead:
		$AnimationPlayer.play("dead")
		velocity.x = 0
	else:
		set_state(State.IDLE)
	pass


func _on_connected_hits_timer_timeout():
	end_connect_hit.emit()
	connected_hit = 0
	pass # Replace with function body.


func _on_can_be_attacked_timer_timeout():
	can_be_attacked = true
	print_debug("Can be attacked")
	pass # Replace with function body.
