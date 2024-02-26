extends Node2D

class_name Game

export(NodePath) onready var ground_tilemap = get_node(ground_tilemap) as Tiling

var players: Array
var influenced_tiles = {}
var current_player = 1

func _ready():
	
	make_player("player1", 1, Color(0.2, 0.2, 0.8))
	make_player("player2", 2,  Color(0.8, 0.2, 0.2))
	
	for player in self.players:
		self.influenced_tiles[player.player_id] = []
	
	debug_setup()
	
	var game_timer: Timer = Timer.new()
	game_timer.set_wait_time(1)
	game_timer.connect("timeout", self, "update")
	add_child(game_timer)
	game_timer.start()
	
	GameEvents.connect("all_tiles_controlled", self, "_on_player_won")
	
	GameState.start()
	
	
func debug_setup():
	"""help starting the game up"""	
	var status_timer: Timer = Timer.new()
	status_timer.set_wait_time(1)
	status_timer.one_shot = true
	status_timer.connect("timeout", self, "_on_first_build")
	add_child(status_timer)
	status_timer.start()
	
	GameEvents.emit_signal("rock_level_changed", self.players[0].rock_amount)

func _on_first_build():
	self.build_building(self.players[-1], Vector2(100,100))
	self.spread_influence(self.players[-1], Vector2(100,100))
	
func _process(delta: float):
	"""Game logic and UI update"""
	
	for player in self.players:
		var income = self.get_influence_income(player)
		var drain = self.get_influence_drain(player)
		
		if player.player_id == current_player:
			GameEvents.emit_signal("water_level_changed", income - drain)
			
	self.ground_tilemap.tile_update()

	
func update():
	"""Game update loop calls this function periodically"""
	for player in self.players:
		self.assign_influence(player, 10)	

func build_building(player: Player, global_location: Vector2):
	var pump = BuildingManager.pump.instance()
	if player.rock_amount >= pump.cost:
		player.rock_amount -= pump.cost
		build_at_location(pump, global_location)
		
		if player.player_id == current_player:
			GameEvents.emit_signal("rock_level_changed", player.rock_amount)
	else:
		pump.queue_free()
		
func get_influence_income(player: Player):
	"""Go over influenced controllers and compute the influence income"""	
	var influence = 0
	for controller in self.influenced_tiles[player.player_id]:
		influence += controller.total_influence(player.player_id)
	return influence

func get_influence_drain(player: Player):
	"""Go over influenced controllers and compute the influence drain
	
	Each non-controlled tile draws 1 influence
	"""	
	var count_of_draining_tiles = 0
	for controller in self.influenced_tiles[player.player_id]:
		var income = controller.total_influence(player.player_id)
		if income == 0:
			count_of_draining_tiles += 1
		
	return count_of_draining_tiles

func assign_influence(player, influence: float):
	"""Go over controllers that we want to increase our influence"""
	
	for controller in self.influenced_tiles[player.player_id]:
		controller.increase_influence(player.player_id, influence)
		
func spread_influence(player: Player, global_location: Vector2):
	"""Mark a tile as target of influence spread"""
	var controller = ground_tilemap.get_controller_for_location(global_location)
	
	print("spreading influence for player ", player.player_id, " and controller ", controller, " at location ", global_location)
	
	if controller == null:
		return
		
	for already_influenced_controller in self.influenced_tiles[player.player_id]:
		if controller == already_influenced_controller:
			return

	self.influenced_tiles[player.player_id].append(controller)

func make_player(name, id, color):
	var player = Player.new()
	player.player_name = name
	player.player_id = id
	player.color = color
	add_child(player)
	players.append(player)
	
func _on_player_won():
	var winner = compute_winner()
	if winner == null:
		print("No winner even though player won!")
		return
		
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
		return

	return winner

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		var tile_pos = ground_tilemap.world_to_map(get_global_mouse_position().snapped(ground_tilemap.cell_size))
		GameEvents.emit_signal("tile_selected", tile_pos)
		
	# A single click
	if event is InputEventMouseButton && event.is_pressed() && event.button_index == BUTTON_LEFT:
		var position = get_global_mouse_position()
		self.build_building(self.players[0], position)
		self.spread_influence(self.players[0], position)
	
func build_at_location(building: Building, global_location: Vector2):

	# setting up building
	var offset = ground_tilemap.cell_size / 2
	offset.y += ground_tilemap.cell_size.y / 4
	building.global_position = ground_tilemap.get_cell_loc_from_world(global_location) + offset
	add_child(building)

	# setting up water level
	var cell = ground_tilemap.get_cell_from_world_loc(global_location)
	var controller =  ground_tilemap.get_controller_for_cell(cell)
	controller.building = building
	controller.set_water_level(controller.water_level + building.water_production)
	
	
