extends Node2D

class_name Player

var player_name
var player_id
var water_amount = 0
var rock_amount = 100
var color: Color


func _ready():
	# TODO: This does not do much atm, might be removed soon
	GameEvents.connect("water_pumped", self, "_on_water_pumped")


func _on_water_pumped(amount: float):
	self.water_amount += amount
