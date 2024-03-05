extends Node2D

class_name Game

export(NodePath) onready var ground_tilemap = get_node(ground_tilemap) as Tiling

var players: Array
var influenced_tiles = {}
var current_player = 1


func _ready():
	make_player("player1", 1, Color(0.2, 0.2, 0.8))
	make_player("player2", 2, Color(0.8, 0.2, 0.2))

	for player in self.players:
		self.influenced_tiles[player.player_id] = []

	debug_setup()

	var game_timer: Timer = Timer.new()
	game_timer.set_wait_time(1)
	game_timer.connect("timeout", self, "update")
	add_child(game_timer)
	game_timer.start()

	GameState.start()


func debug_setup():
	"""help starting the game up"""
	var status_timer: Timer = Timer.new()
	status_timer.set_wait_time(.1)
	status_timer.one_shot = true
	status_timer.connect("timeout", self, "_on_first_build")
	add_child(status_timer)
	status_timer.start()
	#self._on_first_build()

	GameEvents.emit_signal("rock_level_changed", self.players[0].rock_amount)


func _on_first_build():
	var enemy = self.players[0]
	self.build_building(enemy, Vector2(300, 250))
	var controller = ground_tilemap.get_controller_for_location(Vector2(300, 250))
	controller.assign_player(enemy.color, enemy.player_id)
	controller.increase_influence(enemy.player_id, 50)
	mark_tile_influenced(controller, enemy)
	self.spread_influence(enemy, Vector2(300, 250))

	var protagonist = self.players[1]
	self.build_building(protagonist, Vector2(730, 600))
	var controller2 = ground_tilemap.get_controller_for_location(Vector2(730, 600))
	controller2.assign_player(protagonist.color, protagonist.player_id)
	controller2.increase_influence(protagonist.player_id, 50)
	mark_tile_influenced(controller2, protagonist)
	self.spread_influence(protagonist, Vector2(730, 600))

	# Add some water tiles
	ground_tilemap.get_controller_for_location(Vector2(600, 200)).add_tile_modifier(
		TileTypes.TileType.WATER
	)
	ground_tilemap.get_controller_for_location(Vector2(450, 700)).add_tile_modifier(
		TileTypes.TileType.WATER
	)

	# Add a mine
	ground_tilemap.get_controller_for_location(Vector2(600, 400)).add_tile_modifier(
		TileTypes.TileType.MINE
	)


func _process(delta: float):
	"""Game logic and UI update"""

	for player in self.players:
		update_power(player)

	self.ground_tilemap.tile_update()


func update_power(player: Player):
	var income = self.get_influence_income(player)
	var drain = self.get_influence_drain(player)

	if player.player_id == current_player:
		GameEvents.emit_signal("rock_level_changed", player.rock_amount)
		GameEvents.emit_signal("expansion_power_changed", income - drain)
		GameEvents.emit_signal("total_influence_changed", income)


func update():
	"""Game update loop calls this function periodically"""

	if not GameState.running:
		return

	for player in self.players:
		self.assign_influence(player)

		var rock_income = self.get_rock_income(player)
		player.rock_amount += rock_income

	self.check_game_end()


func build_building(player: Player, global_location: Vector2):
	"""Try to build a building at location, only allow one building at a time"""

	var controller = ground_tilemap.get_controller_for_location(global_location)

	# skip building outside of the map
	if !controller:
		return

	# Avoid building two buildings on a tile
	if controller.building:
		return

	var pump = BuildingManager.pump.instance()
	if player.rock_amount >= pump.cost:
		player.rock_amount -= pump.cost
		build_at_location(pump, global_location)
		update_power(player)

	else:
		pump.queue_free()


func get_rock_income(player: Player):
	"""Go over influenced controllers and compute the rock income"""
	var rock = 0
	for controller in self.influenced_tiles[player.player_id]:
		rock += controller.rock_income(player.player_id)
	return rock


func get_influence_income(player: Player):
	"""Go over influenced controllers and compute the influence income"""
	var influence = 0
	for controller in self.influenced_tiles[player.player_id]:
		influence += controller.influence_income(player.player_id)
	return influence


func get_influence_drain(player: Player):
	"""Go over influenced controllers and compute the influence drain
	
	Each non-controlled tile draws influence based on applied pressure
	"""
	var drain = 0
	for controller in self.influenced_tiles[player.player_id]:
		drain += controller.influence_drain(player.player_id)
	return drain


func assign_influence(player):
	"""Go over controllers that we want to increase our influence"""

	for controller in self.influenced_tiles[player.player_id]:
		var drain = controller.influence_drain(player.player_id)
		var control_flipped = controller.increase_influence(player.player_id, drain)
		if control_flipped:
			controller.assign_player(player.color, player.player_id)


func spread_influence(player: Player, global_location: Vector2):
	"""Mark a tile as target of influence spread"""
	var controller = ground_tilemap.get_controller_for_location(global_location)

	print(
		"spreading influence for player ",
		player.player_id,
		" and controller ",
		controller,
		" at location ",
		global_location
	)

	if controller == null:
		return

	var income = self.get_influence_income(player)
	var drain = self.get_influence_drain(player)

	if income - drain <= 0:
		return

	# Apply more pressute to the tile
	controller.increase_influence_pressure(player.player_id, 1)

	# note down that the player influences the tile
	mark_tile_influenced(controller, player)


func mark_tile_influenced(controller: TileController, player: Player):
	""""""
	# Mark the controller as influenced if not already there
	for already_influenced_controller in self.influenced_tiles[player.player_id]:
		if controller == already_influenced_controller:
			return
	self.influenced_tiles[player.player_id].append(controller)


func get_controlled_tiles_for_player(player: Player) -> Array:
	"""Return a list of all cells that the player controls"""
	var cells = {}
	for controller in self.influenced_tiles[player.player_id]:
		if controller.controlling_player_id == player.player_id and controller.influence > 50:
			cells[controller.tile_cell] = controller.tile_cell

	return cells.values()


func make_player(name, id, color):
	var player = Player.new()
	player.player_name = name
	player.player_id = id
	player.color = color
	add_child(player)
	players.append(player)


func check_game_end():
	"""If there is only one player controlling tiles, they win"""

	var winner = self.compute_winner()

	if winner:
		GameEvents.emit_signal("player_won", winner)
		GameState.pause()


func compute_winner():
	"""Check how many tile owning players there are ignoring uncontrolled tiles"""
	var tile_owning_players = {}
	for controller in ground_tilemap.controllers:
		if controller.controlling_player_id != controller.UNCONTROLLED:
			tile_owning_players[controller.controlling_player_id] = controller.controlling_player_id

	if len(tile_owning_players) == 1:
		var winning_id = tile_owning_players.values()[0]

		for player in self.players:
			if player.player_id == winning_id:
				return player
	return null


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		var tile_pos = ground_tilemap.world_to_map(
			get_global_mouse_position().snapped(ground_tilemap.cell_size)
		)
		GameEvents.emit_signal("tile_selected", tile_pos)

	# A single click
	if event is InputEventMouseButton && event.is_pressed() && event.button_index == BUTTON_LEFT:
		var position = get_global_mouse_position()

		# Only spread influence or build if the tile is neighbor of controlled tile
		var cell = ground_tilemap.get_cell_from_world_loc(position)
		if ground_tilemap.cell_is_neighbor_of(
			cell, self.get_controlled_tiles_for_player(self.players[0])
		):
			self.build_building(self.players[0], position)
			self.spread_influence(self.players[0], position)


func build_at_location(building: Building, global_location: Vector2):
	var controller = ground_tilemap.get_controller_for_location(global_location)
	if !controller:
		return

	# setting up building
	var offset = ground_tilemap.cell_size / 2
	offset.y += ground_tilemap.cell_size.y / 4
	building.global_position = ground_tilemap.get_cell_loc_from_world(global_location) + offset
	add_child(building)

	# setting up water level
	controller.building = building
	controller.set_water_level(controller.water_level + building.water_production)
