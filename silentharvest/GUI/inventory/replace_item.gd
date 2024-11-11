class_name ReplaceItem extends CanvasLayer

signal shown
signal hidden
signal replaced

@onready var inventory: InventoryUI = $PanelContainer/Inventory
@onready var new_item: InventoryUI = $PanelContainer2/NewItem

const ITEM_TO_ADD = preload("res://Assets/resources/item_to_add.tres")

var is_paused : bool = false

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	shown.connect(inventory.update_inventory)
	hidden.connect(inventory.clear_inventory)
	replaced.connect(resume_game)
	hide()
	
	
	
func show_menu(item_to_add : ItemData):
	if new_item.data.slots[0] == null:
		print("GO THERE")
		ITEM_TO_ADD.add_item(item_to_add)
		new_item.data.add_item(item_to_add)
	else:
		print("GO HERE INSTEAD")
		new_item.data.replace_item(item_to_add,0,true)
		ITEM_TO_ADD.replace_item(item_to_add,0,true)
	new_item.clear_inventory()
	new_item.update_inventory()
	pause_game()

func pause_game() -> void:
	get_tree().paused = true
	is_paused = true
	show()
	shown.emit()
	pass

func resume_game() -> void:
	get_tree().paused = false
	is_paused = false
	hide()
	hidden.emit()
	pass

func replace_item(slot_index : int) -> void:
	PlayerManager.INVENTORY_DATA.replace_item(new_item.data.slots[0].item_data,slot_index)

	new_item.clear_inventory()
	replaced.emit()
	pass
	
