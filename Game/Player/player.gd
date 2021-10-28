extends Node

class_name Player

var player_name
var player_id
var water_amount = 0
var rock_amount = 100

var pump_resource = preload("res://Game/Buildings/Pump/Pump.tscn")

func _ready():

	GameEvents.connect("water_pumped", self, "_on_water_pumped")	
	init_status_update()
	GameEvents.emit_signal("rock_level_changed", self.rock_amount)
	
func init_status_update():
	var status_timer: Timer = Timer.new()
	status_timer.set_wait_time(1)
	status_timer.connect("timeout", self, "_on_status_update")
	add_child(status_timer)
	status_timer.start()
	
	# this is hack to update rock amount shortly after loading game
	var rock_timer: Timer = Timer.new()
	rock_timer.set_wait_time(0.1)
	rock_timer.one_shot = true
	rock_timer.connect("timeout", self, "_on_status_update")
	add_child(rock_timer)
	rock_timer.start()
	
func _on_status_update():
	GameEvents.emit_signal("water_level_changed", self.water_amount)
	GameEvents.emit_signal("rock_level_changed", self.rock_amount)

func _on_water_pumped(amount: float):
	self.water_amount += amount	

func _unhandled_input(event):	
	if event is InputEventMouseButton && event.is_pressed() && event.button_index == BUTTON_LEFT:
		
		var pump = pump_resource.instance()
		if rock_amount >= pump.cost:
			rock_amount -= pump.cost
			GameEvents.emit_signal("building_added", pump)
		else:
			pump.queue_free()


