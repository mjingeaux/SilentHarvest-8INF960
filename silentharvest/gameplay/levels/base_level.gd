class_name BaseLevel extends Node2D

func add_player(player : Player):
	add_child(player)
	
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	PlayerManager.can_die = true
	
func remove_player(player : Player):
	remove_child(player)
