class_name Camera extends Camera2D
## Follows the player f a n c i l y

const DEBUG := false

## Second-order-system time? Idk...

@onready var target:CharacterBody2D:
	get(): return get_tree().get_first_node_in_group("Player")

var hijack_position:Vector2

var xp:Vector2 # Previous input

# State variables
var y:Vector2
var yd:Vector2

# Dynamic constants
var k1:float
var k2:float
var k3:float

@export var f := 0.75 ## The follow speed.
@export var z := 2.0 ## The bounce/overshoot.
@export var r := 2.15 ## The follow-ahead.

func _ready() -> void:
	_on_reset()
	
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_reset() -> void:
	
	if target:
		global_position = target.global_position
	
	# Compute constants
	k1 = z / (PI * f)
	k2 = 1 / ((2 * PI * f) *  (2 * PI * f))
	k3 = r * z / (2 * PI * f)
	
	# Initialize variables
	var x0 = global_position
	xp = x0
	y = x0
	yd = Vector2.ZERO

func target_position(delta:float): 
	
	var target_pos:Vector2
	
	if hijack_position:
		target_pos = hijack_position
	else:
		target_pos = target.global_position #+ (target.velocity / 3.)
	
	# Compute constants
	k1 = z / (PI * f)
	k2 = 1 / ((2 * PI * f) *  (2 * PI * f))
	k3 = r * z / (2 * PI * f)
	
	var xd:Vector2
	var x = target_pos
	
	xd = (x - xp) / delta
	xp = x
	
	y = y + delta * yd
	yd = yd + delta * (x + k3*xd - y - k1*yd) / k2
	
	return y

var applied_velocity := Vector2.ZERO
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void: 

	if not target:
		target = get_tree().get_first_node_in_group("Player")
		
		global_position = target.global_position
		
		_on_reset()
		
		return
	
	if DEBUG:
		global_position = target.global_position
		zoom = Vector2.ONE * 1.6
		return
	
	global_position = target_position(delta)
