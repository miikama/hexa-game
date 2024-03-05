extends Node2D

class_name TileController

# in ms
var update_interval = 500
var water_level_effect = 500
var max_water_level = 3

var tile_cell

var last_update
var tile_level = 0
var level_changes = [0, 25, 50]
# combine this logic with the above
var tile_modifiers = {}

var water_level = 0

var growing = false
var spread = false

var building: Building
var influence: float = 0

var UNCONTROLLED = 65535
var controlling_player_id = UNCONTROLLED

# How much influence pressure the player_id -> amount of influence
var player_influence: Dictionary = {}

var droplets = []

export(NodePath) onready var area_highlight = get_node(area_highlight) as Sprite
export(NodePath) onready var info_label = get_node(info_label) as RichTextLabel


func _ready():
	last_update = OS.get_ticks_msec()

	droplets = [get_node("Sprite"), get_node("Sprite2"), get_node("Sprite3")]


func influence_drain(player_id: int) -> float:
	"""The players are allowed to apply pressure to tiles

	The influence drain depends on the applied pressure

	At 50 strength, the tile does not drain anymore
	"""
	if not player_id in player_influence:
		return 0.0

	if self.influence >= 100:
		# stop influencing fully controlled tiles
		player_influence[player_id] = 0
	return player_influence[player_id]


func influence_income(player_id: int) -> float:
	"""If the player is controlling player, return positive"""
	if player_id == self.controlling_player_id:
		return self.get_influence_income()
	return 0.0


func increase_influence(player_id: int, influence_increase: float) -> bool:
	"""Increase influence of a player on the tile,
	possibly changing ownership

	return true if ownership flips
	"""
	if player_id == self.controlling_player_id:
		self.influence = min(100.0, self.influence + influence_increase)
		info_label.bbcode_text = "[center]%s[/center]" % self.influence
	else:
		self.influence -= influence_increase

		# if ownership flips
		if self.influence < 0:
			self.influence = -self.influence
			self.controlling_player_id = player_id
			return true
	return false


func increase_influence_pressure(player_id: int, pressure: float):
	"""Increase applied pressure for the player"""
	if player_id in self.player_influence:
		self.player_influence[player_id] += pressure
	else:
		self.player_influence[player_id] = pressure


func get_influence_income():
	"""Always positive"""
	var tile_influence = 0

	if self.influence > 50:
		tile_influence += 2

	if self.building:
		tile_influence += self.building.get_influence_income()

	return tile_influence


func assign_player(player_color: Color, player_id: int):
	self.controlling_player_id = player_id

	area_highlight.visible = true
	area_highlight.material.set_shader_param("color", player_color)

	info_label.visible = true
	info_label.bbcode_text = "[center]%s[/center]" % self.influence
	info_label.modulate = player_color


func set_water_level(level):
	self.water_level = level
	for i in range(droplets.size()):
		if i < level:
			droplets[i].visible = true
		else:
			droplets[i].visible = false


func add_tile_modifier(level):
	"""
	Allow adding extra modifiers to tiles

	level: Tiling.TileType
	"""
	self.tile_modifiers[level] = level


func spread_green(cell, target_tiles):
	if spread:
		return

	# only spread from developed areas
	# tile_map.get_cellv(cell) == tile_map.GROUND_TILE:
	if self.tile_level < self.water_level or self.tile_level == 0:
		return

	if OS.get_ticks_msec() - last_update < update_interval:
		return

	# spread to each neighbouring cell
	#for target_cell in target_tiles:
	#if tile_map.get_cellv(target_cell) == tile_map.GROUND_TILE:
	#GameEvents.emit_signal("spread_to_tile", target_cell, player)

	spread = true


func get_tile_level():
	"""
	Currently, if there are extra modifiers (like water)
	just return the first available
	"""
	for modifier in self.tile_modifiers:
		return modifier

	var tile_level = 0
	for border in self.level_changes:
		if self.influence > border:
			tile_level += 1
	return tile_level
