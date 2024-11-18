class_name InventoryUI extends Control



const INVENTORY_SLOT = preload("res://GUI/inventory/inventory_slot.tscn")
const ITEM_TO_ADD = preload("res://assets/resources/item_to_add.tres")

var data : InventoryData

func _ready() -> void:
	if name == "NewItem":
		data = ITEM_TO_ADD
	else:
		data = PlayerManager.INVENTORY_DATA
	clear_inventory()
	pass


func clear_inventory() -> void:
	for c in get_children():
		c.queue_free()
	pass



func update_inventory() -> void:
	for s in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		add_child(new_slot)
		new_slot.slot_data = s
		if name == "Inventory" and get_parent().get_parent().get_parent().name == "Replace_Item":
			new_slot.pressed.connect(Replace_Item.replace_item.bind(data.slots.find(s)));
	#get_child(0).grab_focus()
