extends CanvasLayer

export(NodePath) onready var menu_dialog = get_node(menu_dialog) as PopupDialog
	
func _unhandled_input(event):
	
	if Input.is_action_just_pressed("menu_open"):
		menu_dialog.popup()
