extends MarginContainer

const option_screen = preload("res://Menu/OptionMenu.tscn")
const tile_screen = preload("res://Game/Map/Hexamap.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Button_pressed():
	ScreenManager.change_screen(ScreenManager.GAME)

func _on_Button2_pressed():
	ScreenManager.change_screen(ScreenManager.OPTIONS)
	
func _on_Button3_pressed():
	get_tree().quit()
