extends Node

const PLAYER = preload("res://gameplay/entities/player/Player.tscn")
const INVENTORY_DATA : InventoryData = preload("res://Assets/resources/player_inventory.tres")
var player : Player
var is_player_in_scene := false
var scene_containing_player : BaseLevel

func _ready() -> void:
	player = PLAYER.instantiate()


func add_player_to_scene(dest_scene : BaseLevel) -> void:
	if (is_player_in_scene):
		player.reparent(dest_scene)
	else:
		is_player_in_scene = true
		dest_scene.add_player(player)
		
	scene_containing_player = dest_scene

func remove_player_from_scene() -> bool:
	if (is_player_in_scene):
		scene_containing_player.remove_player(player)
		is_player_in_scene = false
		return true
	else:
		return false
