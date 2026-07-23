class_name Player extends CharacterBody2D
## The currently active player. We'll have a separate class for
## the recorded ones.

@onready var anim     := $Sprite2D
@onready var atk_anim := $AttackAnim

## The colliders for attacking in each direction.
@onready var attack_colliders:Dictionary[Vector2, CollisionShape2D] = {
	Vector2.UP:    $Area2D/Up,
	Vector2.DOWN:  $Area2D/Down,
	Vector2.LEFT:  $Area2D/Left,
	Vector2.RIGHT: $Area2D/Right,
}

const ATK_INPUTS:Dictionary[String, Vector2] = {
	"AtkRight": Vector2.RIGHT,
	"AtkLeft":  Vector2.LEFT,
	"AtkUp":    Vector2.UP,
	"AtkDown":  Vector2.DOWN,
}

@onready var health := Health.new(20.)

@export var movement_speed        := 50.
@export var movement_acceleration := 14.
@export var movement_friction     := 8.5

@export_group("Dash", "dash_")
@export var dash_speed    := 210.
@export var dash_length   := 0.05
@export var dash_buffer   := 0.1
var dash_buffering := 0.0
@export var dash_cooldown := 3.0
var dash_timer := 0.:
	set(to):
		
		## Trying to end a dash (move from a positive num to 0).
		## Catch that, and put the dash on cooldown.
		if dash_timer > 0 and to == 0:
			dash_timer = -dash_cooldown
		else:
			dash_timer = to
var dash_direction := Vector2.RIGHT

@export_group("Attacking", "attack_")
@export var attack_cooldown := 0.1
@export var attack_damage   := 4.0
@export var attack_buffer   := 0.1
var attack_buffering := 0.0
var attack_timer     := 0.0:
	set(to):
		
		## Trying to end a dash (move from a positive num to 0).
		## Catch that, and put the dash on cooldown.
		if attack_timer > 0 and to == 0:
			attack_timer = -attack_cooldown
			disable_colliders()
		else:
			attack_timer = to
var attack_direction := Vector2.RIGHT

func _ready() -> void:
	
	## Disable all the attack colliders to start.
	disable_colliders()

func _process(delta: float) -> void:
	
	#region Moving
	var move_direction := Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	
	if dash_timer <= 0 and attack_timer <= 0:
		if move_direction:
			
			## Use friction if trying to slow down on an axis, otherwise acceleration.
			var accel := Vector2(
				movement_acceleration if abs(move_direction.x * movement_speed) > abs(velocity.x) else movement_friction,
				movement_acceleration if abs(move_direction.y * movement_speed) > abs(velocity.y) else movement_friction
			)
			
			velocity.x = move_toward(velocity.x, move_direction.x * movement_speed, delta * 60. * accel.x)
			velocity.y = move_toward(velocity.y, move_direction.y * movement_speed, delta * 60. * accel.y)
			
			dash_direction = move_direction
			
		else:
			velocity.x = move_toward(velocity.x, 0.0, delta * movement_friction * 60.)
			velocity.y = move_toward(velocity.y, 0.0, delta * movement_friction * 60.)
		
		anim.play("Walk" if velocity != Vector2.ZERO else "Idle")
	
	#endregion
	
	#region Dashing
	
	## Dash's on cooldown or actively running.
	dash_timer = move_toward(dash_timer, 0., delta)
	
	## Buffer the dash input.
	dash_buffering = move_toward(dash_buffering, 0.0, delta)
	if Input.is_action_just_pressed("Dash"): dash_buffering = dash_buffer
	
	## Can dash and trying to? THEN DO IT.
	if dash_timer == 0. and dash_buffering > 0. and attack_timer <= 0.:
		dash_timer = dash_length
		dash_buffering = 0.
	
	## Currently dashing. Set the velocity to the dash velocity.
	if dash_timer > 0: 
		anim.play("Dash")
		velocity = dash_direction * dash_speed
	
	#endregion
	
	#region Attacking
	
	## Attack's on cooldown or actively running.
	attack_timer = move_toward(attack_timer, 0., delta)
	
	## Buffer the attack input.
	attack_buffering = move_toward(attack_buffering, 0.0, delta)
	for input in ATK_INPUTS:
		if Input.is_action_just_pressed(input):
			attack_direction = ATK_INPUTS[input]
			attack_buffering = attack_buffer
			break
	
	## Can attack and trying to? THEN DO IT.
	if attack_timer == 0. and attack_buffering > 0. and dash_timer <= 0:
		attack_timer = 4.5 / 12 ## 4.5 frames out of 12 frames per second. Length of the attack anim.
		attack_buffering = 0.
		
		anim.play("Attack")
		
		velocity = Vector2.ZERO
		
		atk_anim.stop()
		
		if attack_direction.x != 0:
			atk_anim.play("Horizontal")
			
			atk_anim.flip_h = (attack_direction.x < 0) 
			atk_anim.flip_v = anim.flip_h != (attack_direction.x > 0)
		else:
			atk_anim.play("Vertical")
			
			atk_anim.flip_h = anim.flip_h
			atk_anim.flip_v = (attack_direction.y > 0) 
		 
		
		enable_collider(attack_direction)
	
	#endregion
	
	
	if velocity.x != 0: anim.flip_h = velocity.x < 0
	
	move_and_slide()

## -- Attack Helper Functions -- ##

func disable_colliders() -> void:
	for collider:CollisionShape2D in attack_colliders.values():
		collider.disabled = true

func enable_collider(direction:Vector2) -> void:
	if not attack_colliders.has(direction): return
	
	disable_colliders()
	attack_colliders[direction].disabled = false



func _on_body_hit(body: Node2D) -> void:
	if body is Puck: body.hit(attack_direction * attack_damage)
	print(attack_direction)
	pass # Replace with function body.
