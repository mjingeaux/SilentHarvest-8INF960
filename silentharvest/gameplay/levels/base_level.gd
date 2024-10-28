class_name BaseLevel extends Node2D

func add_player(player : Player):
	add_child(player)
	
func remove_player(player : Player):
	remove_child(player)
