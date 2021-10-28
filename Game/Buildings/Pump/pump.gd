extends Building

class_name Pump

export var pump_effiency = 1

func _ready():	
	var pump_timer: Timer = Timer.new()
	pump_timer.set_wait_time(1)
	pump_timer.connect("timeout", self, "_on_pump_tick")
	add_child(pump_timer)
	pump_timer.start()
	
func _on_pump_tick():
	GameEvents.emit_signal("water_pumped", pump_effiency)
	
	
