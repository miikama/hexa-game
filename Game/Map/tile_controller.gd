extends Node2D

class_name TileController

# in ms
export(float) var update_interval = 2000

var tile_cell
var tile_map

var last_update
var tile_level = 0

var growing = false
var spread = false

func _ready():
	last_update = OS.get_ticks_msec()
	
func start_growing():
	
	if growing:
		return
		
	var update_timer: Timer = Timer.new()
	update_timer.set_wait_time(0.1)
	update_timer.connect("timeout", self, "_on_tile_update")
	add_child(update_timer)
	update_timer.start()
	
	last_update = OS.get_ticks_msec()

func get_tile_level(cell):
	
	var value = tile_map.get_cellv(cell)

	if value < 0:
		return -1
	
	# which value is the current tile in the list of levels
	return tile_map.tile_levels.find(value)
	
func upgrade_tile(cell, tile_level):
	# should one update tiles
	if tile_level >= tile_map.tile_levels.size() -1:
		return
	
	if OS.get_ticks_msec() - last_update > update_interval:
		tile_map.set_cellv(tile_cell, tile_map.tile_levels[tile_level+1])
		tile_map.update_bitmask_area(tile_cell)
		last_update = OS.get_ticks_msec()
		tile_level += 1
		
func spread_green(cell, target_tiles):
	
	if spread:
		return
	
	# only spread from totally developed areas
	if tile_map.get_cellv(cell) != tile_map.tile_levels[-1]:
		return
		
	if OS.get_ticks_msec() - last_update < update_interval:
		return
	
	# spread to each neighbouring cell
	for target_cell in target_tiles:
		if tile_map.get_cellv(target_cell) == tile_map.GROUND_TILE:
			GameEvents.emit_signal("spread_to_tile", target_cell)
			
	spread = true

func _on_tile_update():
		
	tile_level = get_tile_level(tile_cell)
	if tile_level < 0:
		print("Incorrect tile in _on_tile_update()")
		return
	
	upgrade_tile(tile_cell, tile_level)

	spread_green(tile_cell, tile_map.get_neighbours_for_cell(tile_cell))
	
	
	
