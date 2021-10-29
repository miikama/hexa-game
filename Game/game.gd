extends Node2D

var players: Array

export(NodePath) onready var ground_tilemap = get_node(ground_tilemap) as Tiling

func _ready():
	
	make_player("player1", 1)
	make_player("player2", 2)
	
	var status_timer: Timer = Timer.new()
	status_timer.set_wait_time(1)
	status_timer.one_shot = true
	status_timer.connect("timeout", self, "_on_first_build")
	add_child(status_timer)
	status_timer.start()
	
	GameEvents.connect("all_tiles_controlled", self, "_on_player_won")
	GameEvents.connect("building_added", self, "_on_building_added")
	
	GameState.start()
	
func _on_first_build():
	print("making first build")
	players[-1].build_building(Vector2(100,100))
	
func make_player(name, id):
	var player = Player.new()
	player.player_name = name
	player.player_id = id
	add_child(player)
	players.append(player)
	
func _on_player_won():
	var winner = compute_winner()
	print("player won: ", winner)
	if winner:
		GameEvents.emit_signal("player_won", winner)
		GameState.pause()
	
func compute_winner():

	var tile_owning_players = {}
	var winner = null
	var most_tiles = 0
	for controller in ground_tilemap.controllers:
		if controller.player:
			if controller.player in tile_owning_players:
				tile_owning_players[controller.player] += 1
			else:
				tile_owning_players[controller.player] = 1

			if tile_owning_players[controller.player] > most_tiles:
					winner = controller.player
					most_tiles = tile_owning_players[controller.player]

	if winner == null:
		print("nobody won")
		return

	return winner

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		var tile_pos = ground_tilemap.world_to_map(get_global_mouse_position().snapped(ground_tilemap.cell_size))
		GameEvents.emit_signal("tile_selected", tile_pos)
	
func _on_building_added(building: Building, global_location: Vector2):	
	var offset = ground_tilemap.cell_size / 2
	offset.y += ground_tilemap.cell_size.y / 4
	building.global_position = ground_tilemap.get_cell_loc_from_world(global_location) + offset
	add_child(building)
	print("building_added, buildign player: ", building.player)
	ground_tilemap._on_tile_spread(
		ground_tilemap.get_cell_from_world_loc(global_location), building.player)
	
	
