class_name Actor extends Player


func spread_available_influence(game, tile: TileController, available_influence: int):
	"""
	spread at most the given maximum amount of influence to a given tile

	Return: the amount spread
	"""
	var spread_influence = 0

	for i in range(available_influence):
		# Add influence if not full
		if tile.influence < 100:
			# TODO: the global position is the upper left corner so here we
			# add some random seeming amount of pixels to get inside the cell
			game.spread_influence(self, tile.global_position + Vector2(50, 50))
			spread_influence += 1

	return spread_influence


func do_action(game):
	"""
	AI Actor

	1. spread influence to already controlled tiles
	2. if leftover influence, pick random neighbor cell to spread to
	"""

	# How much influence do we have?
	var income = game.get_influence_income(self)
	var drain = game.get_influence_drain(self)
	var available_influence = max(income - drain, 0)
	var spread_influence = 0

	# First use the influence on the owned tiles
	for tile in game.get_influenced_tiles_for_player(self):
		# Stop spreading influence when all has been spread
		if spread_influence >= available_influence:
			break

		spread_influence += self.spread_available_influence(game, tile, available_influence)

	# Loop the already controlled tiles that can be used as a basis for expansion
	for tile in game.get_controlled_tiles_for_player(self):
		# Stop spreading influence when all has been spread
		if spread_influence >= available_influence:
			break

		# The neighbors cells where we could expand to
		var possible_targets = game.ground_tilemap.get_neighbours_for_cell(tile.tile_cell)

		var number_of_targets = len(possible_targets)
		if number_of_targets == 0:
			break

		# pick tile at random
		var target_cell = possible_targets[randi() % number_of_targets]
		var target = game.ground_tilemap.get_controller_for_cell(target_cell)

		spread_influence += self.spread_available_influence(game, target, available_influence)
