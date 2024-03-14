extends PopupDialog

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _unhandled_key_input(event):
	"""Make hidden on esc"""

	if event is InputEventKey and event.scancode == KEY_ESCAPE:
		self.visible = false
