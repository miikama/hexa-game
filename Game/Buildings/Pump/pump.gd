extends Building

class_name Pump

var pump_effiency = 10


func get_influence_income() -> float:
	"""pump is a positive influencer"""
	return self.pump_effiency
