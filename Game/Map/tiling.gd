extends TileMap

class_name Tiling

onready var center = tile_set.tile_get_texture(0).get_size() / 2

const MAP_SIZE = Vector2(8,8)

const GROUND_TILE = 0
const GROUND_1 = 1
const GROUND_2 = 3
const GROUND_3 = 2

const tile_levels = [GROUND_TILE, GROUND_1, GROUND_2, GROUND_3]

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
	GameEvents.connect("spread_to_tile", self, "_on_tile_spread")

	
func make_map():
	for x in MAP_SIZE.x:
		for y in MAP_SIZE.y:
			self.set_cell(x,y, self.GROUND_TILE)

func init_tile_controllers():
	
	for i in range(MAP_SIZE.x):
		var inner_container = []
		for j in range(MAP_SIZE.y):
			var cell = Vector2(i,j)
			if self.get_cellv(cell) >= 0:
				var controller = add_controller(cell)
				inner_container.append(controller)
				free_tiles[cell] = GROUND_TILE
			else:
				break
		controllers.append(inner_container)
		
func get_controller_for_cell(cell: Vector2) -> TileController:
	
	if cell.x < 0 or cell.y < 0 or cell.x >= controllers.size() or cell.y >= controllers[0].size():
		print("querying invalid controller for cell: ", cell)
		return null
		
	return controllers[cell.x][cell.y]

func _on_tile_spread(cell):
	
	var controller = get_controller_for_cell(cell)
	if controller == null:
		return
		
	controller.start_growing()
	free_tiles.erase(cell)
	if free_tiles.size() == 0:
#		GameEvents.emit_signal("player_won", Game.players[0])
		print("skipping game end")

func _unhandled_input(event):
	
	if event is InputEventMouseButton && event.pressed && event.button_index == BUTTON_LEFT:
		var cell = get_cell_from_mouse(get_global_mouse_position())

func add_controller(cell: Vector2):
	if self.get_cellv(cell) != self.GROUND_TILE:
		return
	
	var location = self.map_to_world(cell)
	var controller = tile_controller.instance()
	controller.tile_cell = cell
	controller.global_position = location
	controller.tile_map = self
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
		Vector2(-1,-1),
		Vector2(0,-1),
		Vector2(1,0),
		Vector2(0,1),
		Vector2(-1,1),
		Vector2(-1,0)
	]
	
	var odd_offsets = [
		Vector2(0,-1),
		Vector2(1,-1),
		Vector2(1,0),
		Vector2(1,1),
		Vector2(0,1),
		Vector2(-1,0)
	]
	
	var used_offsets = even_offsets if int(cell.y)  % 2 == 0 else odd_offsets
	var neighbours = []
	for offset in used_offsets:
		var target_cell = cell + offset
		if get_cellv(target_cell) >= 0:
			neighbours.append(target_cell)
			
	return neighbours

func get_cell_loc_from_world(mouse_pos):
	var mouse_cell = self.get_cell_from_mouse(get_global_mouse_position())
	var cell_location = self.map_to_world(mouse_cell)
	return cell_location
	
func get_cell_from_mouse(mouse_pos):
	
	var cell = world_to_map(mouse_pos)
	var local_mouse_pos = mouse_pos - map_to_world(cell)
	
	var slope = (cell_size.y  *  tile_angle_height / tile_wall_height) / (cell_size.x / 2 )
	var b = tile_angle_height / tile_wall_height * cell_size.y
	
	# top left, y - kx -b > 0
	# and invert y axis
	if  local_mouse_pos.y  + slope * local_mouse_pos.x - b < 0:
		if int(cell.y) % 2 == 0:
			return cell + Vector2(-1,-1)
		else:
			return cell + Vector2(0,-1)

	# top right, y - kx - b > 0
	# invert y axis and shift origin in x-direction hexa center
	if  local_mouse_pos.y  - slope * (local_mouse_pos.x - cell_size.x/2)  < 0:
		if int(cell.y) % 2 == 0:
			return cell + Vector2(0,-1)
		else:
			return cell + Vector2(1, -1)
#
	return cell
	

	
