extends TileMap

class_name Tiling

var center = tile_set.tile_get_texture(0).get_size() / 2

const MAP_SIZE = Vector2(8, 8)

const GROUND_TILE = 0
const GROUND_1 = 1
const GROUND_2 = 3
const GROUND_3 = 2
const WATER = 4
const MINE = 5

const tile_levels = [GROUND_TILE, GROUND_1, GROUND_2, GROUND_3, WATER, MINE]

enum TileType {
	GROUND = 0,
	GREEN1 = 1,
	GREEN2 = 3,
	GREEN3 = 2,
	WATER = 4,
	MINE = 5,
}

# constants from the tile graphics
const tile_angle_height = 35.0
const tile_wall_height = 105.0
const total_height = tile_angle_height * 2 + tile_wall_height

var tile_controller = preload("res://Game/Map/tile_controller.tscn")

var free_tiles = {}
var controllers = []


func _ready():
	make_map()
	init_tile_controllers()


func make_map():
	for x in MAP_SIZE.x:
		for y in MAP_SIZE.y:
			self.set_cell(x, y, self.GROUND_TILE)


func init_tile_controllers():
	# NOTE: only supports continuous rectangular grids
	for i in range(MAP_SIZE.x):
		for j in range(MAP_SIZE.y):
			var cell = Vector2(i, j)
			if self.get_cellv(cell) >= 0:
				var controller = add_controller(cell)
				controllers.append(controller)
				free_tiles[cell] = GROUND_TILE
			else:
				break


func tile_update():
	for controller in self.controllers:
		var tile_level = controller.get_tile_level()
		self.change_tile_level(controller.tile_cell, tile_level)


func get_controller_for_cell(cell: Vector2) -> TileController:
	if cell.x < 0 or cell.y < 0 or (MAP_SIZE.y * cell.x + cell.y) >= controllers.size():
		print("querying invalid controller for cell: ", cell)
		return null

	return controllers[MAP_SIZE.y * cell.x + cell.y]


func get_controller_for_location(global_location: Vector2) -> TileController:
	var cell = self.get_cell_from_world_loc(global_location)
	return self.get_controller_for_cell(cell)


func determine_cell_water_level(cell):
	var neighbour_cells = get_neighbours_for_cell(cell)
	var max_neighbour_level = 0
	for neighbour in neighbour_cells:
		var controller = get_controller_for_cell(neighbour)
		max_neighbour_level = max(max_neighbour_level, controller.water_level)

	return max(max_neighbour_level - 1, 0)


func _unhandled_input(event):
	if event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT:
		var cell = get_cell_from_world_loc(get_global_mouse_position())


func add_controller(cell: Vector2):
	if self.get_cellv(cell) != self.GROUND_TILE:
		return

	var location = self.map_to_world(cell)
	var controller = tile_controller.instance()
	controller.tile_cell = cell
	controller.global_position = location
	controller.tile_level = 0
	add_child(controller)
	return controller


func get_tile_level(cell):
	var value = self.get_cellv(cell)

	if value < 0:
		return -1

	# which value is the current tile in the list of levels
	return self.tile_levels.find(value)


func change_tile_level(cell, new_level):
	var current_level = get_tile_level(cell)
	if GameState.running:
		self.set_cellv(cell, self.tile_levels[new_level])
		self.update_bitmask_area(cell)
		return new_level
	return current_level


func get_neighbours_for_cell(cell):
	var even_offsets = [
		Vector2(-1, -1),
		Vector2(0, -1),
		Vector2(1, 0),
		Vector2(0, 1),
		Vector2(-1, 1),
		Vector2(-1, 0)
	]

	var odd_offsets = [
		Vector2(0, -1), Vector2(1, -1), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), Vector2(-1, 0)
	]

	var used_offsets = even_offsets if int(cell.y) % 2 == 0 else odd_offsets
	var neighbours = []
	for offset in used_offsets:
		var target_cell = cell + offset
		if get_cellv(target_cell) >= 0:
			neighbours.append(target_cell)

	return neighbours


func get_cell_loc_from_world(global_location: Vector2):
	var cell = self.get_cell_from_world_loc(global_location)
	var cell_location = self.map_to_world(cell)
	return cell_location


func get_cell_from_world_loc(global_location: Vector2):
	var cell = world_to_map(global_location)
	var local_mouse_pos = global_location - map_to_world(cell)

	var slope = (cell_size.y * tile_angle_height / tile_wall_height) / (cell_size.x / 2)
	var b = tile_angle_height / tile_wall_height * cell_size.y

	# top left, y - kx -b > 0
	# and invert y axis
	if local_mouse_pos.y + slope * local_mouse_pos.x - b < 0:
		if int(cell.y) % 2 == 0:
			return cell + Vector2(-1, -1)
		else:
			return cell + Vector2(0, -1)

	# top right, y - kx - b > 0
	# invert y axis and shift origin in x-direction hexa center
	if local_mouse_pos.y - slope * (local_mouse_pos.x - cell_size.x / 2) < 0:
		if int(cell.y) % 2 == 0:
			return cell + Vector2(0, -1)
		else:
			return cell + Vector2(1, -1)
#
	return cell
