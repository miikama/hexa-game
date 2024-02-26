extends MarginContainer

const option_screen = preload("res://Menu/OptionMenu.tscn")
const tile_screen = preload("res://Game/Map/Hexamap.tscn")


func _on_Button_pressed():
	ScreenManager.change_screen(ScreenManager.GAME)


func _on_Button2_pressed():
	ScreenManager.change_screen(ScreenManager.OPTIONS)


func _on_Button3_pressed():
	get_tree().quit()
