class_name Inventory extends Node

const SIZE : int = 30
var storage : Dictionary
var itemCount : int

# Called when the node enters the scene tree for the first time.
func init() -> void:
	for itemType in GlobalEnum.EitemType:
		storage[itemType] = 0;
		print("inventory initialised to ")
		print(str(itemType) + str(storage[itemType]))

func has_item(item_type,quantity = 1):
	if storage.get(item_type, 0) >= quantity:
		return true
	return false

func remove_item(item_type,quantity = 1):
	if storage[item_type] >= quantity:
		storage[item_type] -= quantity
		itemCount -= 1
	
func add_item(item_type : GlobalEnum.EitemType,quantity = 1) -> bool:
	if itemCount >= SIZE:
		return false
	storage[item_type] = storage.get(item_type,0) + quantity
	itemCount += 1
	return true

func show_item(item_type):
	return storage.get(item_type, 0)

func replace_item(old_item : GlobalEnum.EitemType,new_item : GlobalEnum.EitemType):
	if has_item(old_item):
		storage[old_item] = storage.get(old_item,0) - 1
		storage[new_item] = storage.get(new_item,0) + 1
	pass
