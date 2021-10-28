extends Camera2D


# Declare member variables here. Examples:
var mouse_start_pos = Vector2.ZERO
var screen_start_pos = Vector2.ZERO
var dragging = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_MIDDLE:
		if event.is_pressed():
			mouse_start_pos = event.position
			screen_start_pos = position
			dragging = true
		else:
			dragging = false

	if event is InputEventMouseMotion and dragging:
		position = zoom * (mouse_start_pos - event.position) + screen_start_pos
		
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				#zoom_pos = get_global_mouse_position()
				var current_zoom = get_zoom() * 0.9
				var new_zoom = Vector2(max(0.3, current_zoom.x), max(0.3,current_zoom.y))
				set_zoom(new_zoom)
				
			if event.button_index == BUTTON_WHEEL_DOWN:
				#zoom_pos = get_global_mouse_position()
				var current_zoom = get_zoom() * 1.1
				var new_zoom = Vector2(min(1.3, current_zoom.x), min(1.3,current_zoom.y))
				set_zoom(new_zoom)
