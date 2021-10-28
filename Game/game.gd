extends Node2D

var players: Array

export(NodePath) onready var ground_tilemap = get_node(ground_tilemap) as Tiling

func _ready():
	var player = Player.new()
	player.player_name = "player1"
	player.player_id = 1
	add_child(player)
	players.append(player)
	
	GameEvents.connect("player_won", self, "_on_player_won")
	GameEvents.connect("building_added", self, "_on_building_added")
	
func _on_player_won(player):
	print("player won: ", player)
	GameState.pause()
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		var tile_pos = ground_tilemap.world_to_map(get_global_mouse_position().snapped(ground_tilemap.cell_size))
		GameEvents.emit_signal("tile_selected", tile_pos)
	
func _on_building_added(building):	
	var offset = ground_tilemap.cell_size / 2
	offset.y += ground_tilemap.cell_size.y / 4
	building.global_position = ground_tilemap.get_cell_loc_from_world(get_global_mouse_position()) + offset
	add_child(building)
	ground_tilemap._on_tile_spread(ground_tilemap.get_cell_from_mouse(get_global_mouse_position()))
	
	
