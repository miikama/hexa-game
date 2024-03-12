extends Node

var pump = preload("res://Game/Buildings/Pump/Pump.tscn")
var mine = preload("res://Game/Buildings/Mine/Mine.tscn")

enum BuildingType {
	Pump,
	Mine,
}


func get_building_of_type(building_type: int):
	"""Instantiate a building of argument type"""

	if building_type == BuildingType.Pump:
		return BuildingManager.pump.instance()
	elif building_type == BuildingType.Mine:
		return BuildingManager.mine.instance()
	else:
		return null
