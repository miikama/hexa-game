extends CanvasLayer

export(NodePath) onready var menu_dialog = get_node(menu_dialog) as PopupDialog
export(NodePath) onready var victory_dialog = get_node(victory_dialog)


func _ready():
	GameEvents.connect("player_won", self, "_on_player_won")
	GameEvents.connect("quit_to_main_menu", self, "_on_quit_to_main_menu")
	GameEvents.connect("quit_to_desktop", self, "_on_exit")


func _on_player_won(player):
	victory_dialog.set_player(player)
	victory_dialog.visible = true


func _unhandled_input(event):
	if Input.is_action_just_pressed("menu_open"):
		menu_dialog.popup()


func _on_quit_to_main_menu():
	ScreenManager.change_screen(ScreenManager.MENU)


func _on_exit():
	get_tree().quit()
