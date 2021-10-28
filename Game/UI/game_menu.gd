extends PopupDialog

func _on_MainMenuButton_pressed():
	GameEvents.emit_signal("quit_to_main_menu")


func _on_QuitButton_pressed():
	GameEvents.emit_signal("quit_to_desktop")
