class_name BodySelector extends ColorRect

@export var animator:AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var children := $HBoxContainer.get_children()
	for i in children.size(): 
		var child := children[i]
		if child is SelectionEntry:
			child.pressed.connect(_selected.bind(i))
	
	Global.attempt_over.connect(
		func(): 
			animator.play("Selector->Game", -1, -1., true)
			
			for i in children.size(): 
				var child := children[i]
				if child is SelectionEntry:
					child._update()
	)
	

func _selected(index:int) -> void:
	
	animator.play("Selector->Game")
	
	Global.begin_attempt(index)
	
	pass
