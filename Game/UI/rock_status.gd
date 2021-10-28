extends Label

export(NodePath) onready var label = get_node(label) as Label

func _ready():
	GameEvents.connect("water_level_changed", self, "_on_water_level_changed")
	
func _on_water_level_changed(new_level):
	label.text = str(new_level)
