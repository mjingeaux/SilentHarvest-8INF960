class_name BaseLevel extends Node2D

@onready var player_start: Marker2D = $PlayerStart

func add_player(player : Player):
	add_child(player)
	await ready
	player.global_position = player_start.global_position
	
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	PlayerManager.can_die = true
	
func remove_player(player : Player):
	remove_child(player)
	
