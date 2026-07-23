class_name Puck extends CharacterBody2D

# The conversion rate between force and speed.
const CONVERSION_RATE := 0.5

const HITSTOP_LENGTH := 0.4
var hitstop_timer := 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	if hitstop_timer > 0.0:
		$Sprite2D.offset = Vector2(randf(), randf()) * 2.
		hitstop_timer = move_toward(hitstop_timer, 0.0, delta)
	else:
		$Sprite2D.offset = Vector2.ZERO
		
		var collision_info = move_and_collide(velocity * delta)
		if collision_info:
			velocity = velocity.bounce(collision_info.get_normal())

func hit(with:Vector2):
	var direction := with.normalized()
	
	hitstop_timer = HITSTOP_LENGTH
	
	velocity = velocity.bounce(direction) + with
