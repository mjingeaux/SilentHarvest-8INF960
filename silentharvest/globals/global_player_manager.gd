extends Node

const PLAYER = preload("res://gameplay/entities/player/Player.tscn")
var INVENTORY_DATA : InventoryData = preload("res://assets/resources/player_inventory.tres")
var ITEM_PICKUP = preload("res://gameplay/entities/items/item_pickup.tscn")
var player : Player
var is_player_in_scene := false
var scene_containing_player : BaseLevel

var can_die := false

func _ready() -> void:
	INVENTORY_DATA.full_inventory.connect(Replace_Item.show_menu)  
	player = PLAYER.instantiate()


func add_player_to_scene(dest_scene : BaseLevel) -> void:
	if (is_player_in_scene):
		player.reparent(dest_scene)
	else:
		is_player_in_scene = true
		dest_scene.add_player(player)
		
	scene_containing_player = dest_scene
	player.global_position = Vector2i(0,0)

func remove_player_from_scene() -> bool:
	if (is_player_in_scene):
		scene_containing_player.remove_player(player)
		is_player_in_scene = false
		return true
	else:
		return false
		
func drop_item(item : ItemData, position : Vector2) -> void:
	var new_item_pickup = ITEM_PICKUP.instantiate()
	new_item_pickup.item_data = item
	new_item_pickup.global_position = position
	scene_containing_player.add_child(new_item_pickup)
	
func clear_inventory() -> void:
	for i in INVENTORY_DATA.slots.size():
		INVENTORY_DATA.slots[i] = null
	INVENTORY_DATA.score = 0
