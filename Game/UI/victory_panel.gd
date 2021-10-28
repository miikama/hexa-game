extends Panel

export(NodePath) onready var victory_label = get_node(victory_label) as Label

func set_player(player: Player):
	victory_label.text = player.player_name + " won!"

func _on_MenuButton_pressed():
	GameEvents.emit_signal("quit_to_main_menu")
