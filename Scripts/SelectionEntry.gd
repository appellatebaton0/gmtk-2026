class_name SelectionEntry extends PanelContainer
## Literally just a button, pretty much.

signal pressed

func _ready() -> void:
	$MarginContainer/VBoxContainer/Button.pressed.connect(pressed.emit)
	$MarginContainer/VBoxContainer/Delete.pressed.connect(
		func():
			Global.current_level.attempts[get_index()] = null
			_update()
	)
	
	$MarginContainer/VBoxContainer/Label.text = "BODY " + str(get_index() + 1)

func _update():
	$MarginContainer/VBoxContainer/Delete.visible = Global.current_level.attempts[get_index()] != null
