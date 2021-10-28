extends Node

enum {
	MENU,
	OPTIONS,
	GAME,
}

const screens = {
	MENU: "res://Menu/MainMenu.tscn",
	OPTIONS: "res://Menu/OptionMenu.tscn",
	GAME: "res://Game/Map/Hexamap.tscn",
}

func change_screen(target_screen):
	
	if not target_screen in screens:
		return
	get_tree().change_scene(screens[target_screen])	

func _ready():	
	print("started screen manager")
	
