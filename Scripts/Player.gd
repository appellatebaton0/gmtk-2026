class_name Player extends CharacterBody2D
## The currently active player. We'll have a separate class for
## the recorded ones.

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
@export var attack_cooldown := 2.0
@export var attack_damage   := 4.0
var attack_timer := 0.

func _process(delta: float) -> void:
	
	#region Moving
	var move_direction := Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	
	if dash_timer <= 0:
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
	#endregion
	
	#region Dashing
	
	## Dash's on cooldown or actively running.
	dash_timer = move_toward(dash_timer, 0., delta)
	
	## Buffer the dash input.
	dash_buffering = move_toward(dash_buffering, 0.0, delta)
	if Input.is_action_just_pressed("Dash"): dash_buffering = dash_buffer
	
	## Can dash and trying to? THEN DO IT.
	if dash_timer == 0. and dash_buffering > 0.:
		dash_timer = dash_length
		dash_buffering = 0.
	
	## Currently dashing. Set the velocity to the dash velocity.
	if dash_timer > 0: velocity = dash_direction * dash_speed
	
	#endregion
	
	
	move_and_slide()
