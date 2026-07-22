class_name Health extends Resource
## A self-contained resource to manage a class's health. Composition! (Is this an interface?)

signal damage_taken
signal died

var _max_health:float
var _health:float

## Upon creation, initialize the max health and health.
func _init(max_health:float) -> void:
	_max_health = max_health
	_health = _max_health

func get_health() -> float: return _health

func take_damage(amount:float) -> void:
	if amount <= 0: return # I don't think we'll be doing anything with regen, so don't bother allowing it.
	
	_health = max(_health - amount, 0)
	
	damage_taken.emit()
	if _health == 0: died.emit()
