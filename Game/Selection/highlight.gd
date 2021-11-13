extends Node2D

export var highlight_color: Color = Color("#2e56f5")

const highlight_sprite = preload("res://Game/Map/highlight_hexa.tscn")
var highlight

export(NodePath) onready var ground_tilemap = get_node(ground_tilemap) as Tiling

func _ready():
	make_highlight()
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var cell = ground_tilemap.get_cell_from_world_loc(get_global_mouse_position())
		if ground_tilemap.get_cellv(cell) < 0:
			self.visible = false
			return
		else:
			self.visible = true
		highlight.global_position = ground_tilemap.get_cell_loc_from_world(get_global_mouse_position())

func make_highlight():
	highlight = highlight_sprite.instance()
	highlight.modulate = highlight_color	
	highlight.global_position = ground_tilemap.get_cell_loc_from_world(get_global_mouse_position()) # get_global_mouse_position().snapped(TILE_SIZE)
	add_child(highlight)
