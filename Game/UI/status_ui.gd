extends Control

export(NodePath) onready var water_label = get_node(water_label) as Label
export(NodePath) onready var rock_label = get_node(rock_label) as Label


func _ready():
	GameEvents.connect("water_level_changed", self, "_on_water_level_changed")
	GameEvents.connect("rock_level_changed", self, "_on_rock_level_changed")


func _on_water_level_changed(new_level):
	water_label.text = str(new_level)


func _on_rock_level_changed(new_level):
	rock_label.text = str(new_level)


func _on_Button_pressed():
	print("pressed")
	#Input.emit_signal("menu_open")
	var ev = InputEventAction.new()
	ev.action = "menu_open"
	ev.pressed = true
	Input.parse_input_event(ev)
