extends Node2D

class_name Building

export var cost := 0
export var water_production := 0


func get_influence_income() -> float:
	"""base class"""
	return 0.0
