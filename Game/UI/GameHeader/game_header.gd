extends Control

export(NodePath) onready var expansion_power_label = get_node(expansion_power_label) as Label
export(NodePath) onready var total_influence_label = get_node(total_influence_label) as Label
export(NodePath) onready var rock_label = get_node(rock_label) as Label


func _ready():
	GameEvents.connect("expansion_power_changed", self, "_on_expansion_power_changed")
	GameEvents.connect("total_influence_changed", self, "_on_total_influence_changed")
	GameEvents.connect("rock_level_changed", self, "_on_rock_level_changed")


func _on_expansion_power_changed(new_level):
	expansion_power_label.text = str(new_level)


func _on_total_influence_changed(new_level):
	total_influence_label.text = str(new_level)


func _on_rock_level_changed(new_level):
	rock_label.text = str(new_level)


func _on_Button_pressed():
	print("pressed")
	#Input.emit_signal("menu_open")
	var ev = InputEventAction.new()
	ev.action = "menu_open"
	ev.pressed = true
	Input.parse_input_event(ev)
