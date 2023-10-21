extends CharacterBody2D

class_name Dummy

@export var SPEED : float = 300.0
@export var JUMP_VELOCITY = -400.0

@export var id : int = 0
@export var hp : int = 2
@export var enemy_player : Dummy

signal hp_update(hp)

enum State {
	IDLE,
	RUN,
	JUMP,
	ATTACK,
	SPECIAL,
	HIT
}
@export var current_state : State = State.IDLE

var facing_direction : Vector2 = Vector2.RIGHT

@export var attack_collision : CollisionShape2D
@export var attack_area : Area2D

var can_attack : bool = true

@export var player_layer : int
@export var attack_layer : int
@export var enemy_layer : int

@export var special_scene : PackedScene

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready(): #Start()
	set_collision_layer_value(player_layer, true )
	set_collision_mask_value(enemy_layer, true)
	attack_area.set_collision_layer_value(attack_layer, true)
	attack_area.set_collision_mask_value(enemy_layer, true)
	set_state(State.IDLE)
	pass

func _process(delta): #Update()
	$Visible.scale.x = facing_direction.x
	_fsm()
	pass

func _fsm():
	match current_state:
		State.IDLE:
			if Input.is_action_just_pressed("attack" + str(id)) and can_attack:
				set_state(State.ATTACK)
			if Input.is_action_just_pressed("special" + str(id)) and can_attack:
				set_state(State.SPECIAL)
			if is_on_floor():
				if abs(velocity.x) > 0:
					set_state(State.RUN)
				if Input.is_action_just_pressed("jump" + str(id)):
					set_state(State.JUMP)
		State.RUN:
			if is_on_floor():
				if abs(velocity.x) < 0.1:
					set_state(State.IDLE)
				if Input.is_action_just_pressed("jump" + str(id)):
					set_state(State.JUMP)
			if Input.is_action_just_pressed("attack" + str(id)) and can_attack:
				set_state(State.ATTACK)
			if Input.is_action_just_pressed("special" + str(id)) and can_attack:
				set_state(State.SPECIAL)
		State.JUMP:
			if Input.is_action_just_pressed("attack" + str(id)) and can_attack:
				set_state(State.ATTACK)
			if Input.is_action_just_pressed("special" + str(id)) and can_attack:
				set_state(State.SPECIAL)
			if is_on_floor():
				if abs(velocity.x) > 0:
					set_state(State.RUN)
				else:
					set_state(State.IDLE)
		State.ATTACK:
			pass
	pass

func set_state(new_state : State):
	current_state = new_state
	match current_state:
		State.IDLE:
			_idle_state()
		State.RUN:
			_run_state()
		State.ATTACK:
			_attack_state()
		State.JUMP:
			_jump_state()
		State.SPECIAL:
			_special_state()
	pass

func _idle_state():
	$AnimationPlayer.play("idle")
	pass

func _run_state():
	$AnimationPlayer.play("run")
	pass

func _attack_state():
	attack()
	pass

func _jump_state():
	velocity.y = JUMP_VELOCITY
	#$AnimationPlayer.play("jump")
	pass

func _special_state():
	velocity.y = 0
	var special = special_scene.instantiate()
	get_tree().root.add_child(special)
	special.init(global_position, facing_direction, attack_layer, enemy_layer)
	await get_tree().create_timer(0.5).timeout
	can_attack = true
	set_state(State.IDLE)
	pass

func _physics_process(delta): #FixedUpdate()
	if can_attack:
		if enemy_player.global_position.x < global_position.x:
			facing_direction = Vector2.LEFT
		else:
			facing_direction = Vector2.RIGHT
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
	velocity.x = facing_direction.x * SPEED * 1.1
	pass

func attack():
	if not can_attack: return
	can_attack = false
	$AnimationPlayer.play("attack")
	await get_tree().create_timer(0.5).timeout
	can_attack = true
	set_state(State.IDLE)
	pass

func _on_attack_area_body_entered(body):
	var dummy : Dummy = body as Dummy
	dummy.take_damage(1)
	pass # Replace with function body.

func take_damage(damage : int):
	hp -= damage
	$AnimationPlayer.play("hit")
	hp_update.emit(hp)
	pass


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "hit":
		$AnimationPlayer.play("idle")
	if anim_name == "attack":
		$AnimationPlayer.play("idle")
	pass # Replace with function body.
