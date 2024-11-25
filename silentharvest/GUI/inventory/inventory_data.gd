class_name InventoryData extends Resource

signal full_inventory(to_add : ItemData)
signal item_added

@export var slots : Array[SlotData]

var score : int = 0

func _init() -> void:
	connect_slots()
	pass

func add_item(item : ItemData) -> int:
	for i in slots.size():
		if slots[i] == null:
			var new_slot = SlotData.new()
			new_slot.item_data = item
			slots[i] = new_slot
			new_slot.changed.connect(slot_changed)
			score += item.value
			item_added.emit()
			print("THE SCORE IS UPDATED")
			print(score)
			return score
	printerr("NEVER GO THERE")
	full_inventory.emit(item)
	return score

func replace_item(item : ItemData, index: int,is_pickup_item : bool = false) -> void:
	if item == null:
		if (slots[index] != null):
			score -= slots[index].item_data.value
			slots[index] = null
	else :
		score += item.value - slots[index].item_data.value
		if !is_pickup_item:
			var position = PlayerManager.player.global_position
			PlayerManager.drop_item(slots[index].item_data,position)
		slots[index].item_data = item
		slots[index].changed.connect(slot_changed)

	
func connect_slots() -> void:
	for s in slots:
		if s:
			s.changed.connect(slot_changed)
			

func slot_changed() -> void:
	for s in slots:
		if s:
			if s.empty:
				s.changed.disconnect(slot_changed)
				var index = slots.find(s)
				slots[index] = null
	emit_changed()
	pass
