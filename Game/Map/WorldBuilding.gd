extends Node2D






const highlight_color = Color("#2e56f5")

const highlight_sprite = preload("res://Game/Map/highlight_hexa.tscn")
var highlight

export(NodePath) onready var ground_tilemap = get_node(ground_tilemap) as Tiling


func _ready():
	make_highlight()
	
	GameEvents.connect("building_added", self, "_on_building_added")

	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		highlight.global_position = ground_tilemap.get_cell_loc_from_world(get_global_mouse_position())
		
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		var tile_pos = ground_tilemap.world_to_map(get_global_mouse_position().snapped(ground_tilemap.cell_size))
		
		GameEvents.emit_signal("tile_selected", tile_pos)
	


func make_highlight():
	highlight = highlight_sprite.instance()
	highlight.modulate = highlight_color	
	highlight.global_position = ground_tilemap.get_cell_loc_from_world(get_global_mouse_position()) # get_global_mouse_position().snapped(TILE_SIZE)
	add_child(highlight)	
	
func _on_building_added(building):
	
	var offset = ground_tilemap.cell_size / 2
	offset.y += ground_tilemap.cell_size.y / 4
	building.global_position = ground_tilemap.get_cell_loc_from_world(get_global_mouse_position()) + offset
	add_child(building)
	#ground_tilemap.add_controller(
#		ground_tilemap.get_cell_from_mouse(get_global_mouse_position()))
	ground_tilemap._on_tile_spread(ground_tilemap.get_cell_from_mouse(get_global_mouse_position()))
	
	
