extends Node

var players: Array

func _ready():	
	var player = Player.new()
	add_child(player)
	players.append(player)
	
