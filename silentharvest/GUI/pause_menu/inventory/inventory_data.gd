class_name InventoryData extends Resource

@export var slots : Array[SlotData]

func add_item(item : ItemData) -> bool:
	for i in slots.size():
		if slots[i] == null:
			var new_slot = SlotData.new()
			new_slot.item_data = item
			slots[i] = new_slot
			print("ITEM ADDED : ")
			print(slots)
			return true
	print("ITEM NOT ADDED !")
	print(slots)
	return false
