class_name InventoryUI extends Control



const INVENTORY_SLOT = preload("res://GUI/inventory/inventory_slot.tscn")
const ITEM_TO_ADD = preload("res://assets/resources/item_to_add.tres")

var data : InventoryData

func _ready() -> void:
	if name == "NewItem":
		data = ITEM_TO_ADD
	else:
		data = PlayerManager.INVENTORY_DATA
	create_inventory()
	pass

func _process(delta: float) -> void:
	update_inventory()

func create_inventory() -> void:
	for s in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		add_child(new_slot)
		new_slot.slot_data = s
		
func clear_inventory() -> void:
	for c in get_children():
		c.queue_free()
	pass
	
func update_inventory() -> void:
	var children = get_children()
	for i in data.slots.size():
		children[i].slot_data = data.slots[i]
		if name == "Inventory":
			if get_parent().get_parent().get_parent().name == "Replace_Item":
				if (children[i].pressed.is_connected(drop_item)):
					children[i].pressed.disconnect(drop_item)
				if (!children[i].pressed.is_connected(Replace_Item.replace_item)):
					children[i].pressed.connect(Replace_Item.replace_item.bind(i))
					
			else :
				if (children[i].pressed.is_connected(Replace_Item.replace_item)):
					children[i].pressed.disconnect(Replace_Item.replace_item)
				if (!children[i].pressed.is_connected(drop_item)):
					children[i].pressed.connect(drop_item.bind(i))
		
func drop_item(index : int) -> void:
	data.replace_item(null,index)
	var children = get_children()
	if children[index].slot_data != null:
		PlayerManager.drop_item(children[index].slot_data.item_data,PlayerManager.player.global_position)
		children[index].slot_data = data.slots[index]
		update_inventory()
	children[index].release_focus()
	
