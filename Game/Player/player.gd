extends Node2D

class_name Player

var player_name
var player_id
var water_amount = 0
var rock_amount = 100
var color: Color


func init(name: String, player_id: int, color: Color):
	"""Setup fields"""
	self.player_name = name
	self.player_id = player_id
	self.color = color


func _ready():
	# TODO: This does not do much atm, might be removed soon
	GameEvents.connect("water_pumped", self, "_on_water_pumped")


func _on_water_pumped(amount: float):
	self.water_amount += amount


func do_action(game):
	""""""
	pass
