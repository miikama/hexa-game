extends Node2D

class_name TileController

# in ms
export(float) var update_interval = 500
export(float) var water_level_effect = 500
export(float) var max_water_level = 3

var tile_cell
var tile_map

var last_update
var tile_level = 0

var water_level = 0

var growing = false
var spread = false


var player: Player
var building: Building

var droplets = []

export(NodePath) onready var area_highlight = get_node(area_highlight) as Sprite

func _ready():
	last_update = OS.get_ticks_msec()
	
	droplets = [get_node("Sprite"), get_node("Sprite2"), get_node("Sprite3")]

	
func start_growing():
	
	if growing:
		return
		
	var update_timer: Timer = Timer.new()
	update_timer.set_wait_time(0.1)
	update_timer.connect("timeout", self, "_on_tile_update")
	add_child(update_timer)
	update_timer.start()
	
	last_update = OS.get_ticks_msec()
	
	growing = true

func assign_player(player: Player):
	self.player = player
	area_highlight.visible = true
	area_highlight.material.set_shader_param("color", player.color)
	
func set_water_level(level):
	self.water_level = level
	for i in range(droplets.size()):
		if i < level:
			droplets[i].visible = true
		else:
			droplets[i].visible = false
	
func upgrade_tile(cell, tile_level):

	# should one update tiles
	# if tile_level >= tile_map.tile_levels.size() -1:
	if self.tile_level >= self.water_level:
		return
	
	var water_level_delay = (max_water_level- self.water_level) * self.water_level_effect
	if OS.get_ticks_msec() - last_update > (update_interval + water_level_delay):
		var old_level = tile_level
		tile_level = tile_map.change_tile_level(cell, tile_level + 1)
		if tile_level != old_level:
			last_update = OS.get_ticks_msec()

func spread_green(cell, target_tiles):
	
	if spread:
		return
	
	# only spread from developed areas
	# tile_map.get_cellv(cell) == tile_map.GROUND_TILE:
	if self.tile_level < self.water_level or self.tile_level ==  0:
		return
		
	if OS.get_ticks_msec() - last_update < update_interval:
		return
	
	# spread to each neighbouring cell
	for target_cell in target_tiles:
		if tile_map.get_cellv(target_cell) == tile_map.GROUND_TILE:
			GameEvents.emit_signal("spread_to_tile", target_cell, player)
			
	spread = true

func _on_tile_update():
		
	tile_level = tile_map.get_tile_level(tile_cell)
	if tile_level < 0:
		print("Incorrect tile in _on_tile_update()")
		return
	
	upgrade_tile(tile_cell, tile_level)

	spread_green(tile_cell, tile_map.get_neighbours_for_cell(tile_cell))
	
	
	
