class_name InventorySlotUI extends Button

var slot_data : SlotData : set = set_slot_data

@onready var texture_rect: TextureRect = $TextureRect


func ready() -> void:
	texture_rect.texture = null
	 
 
func set_slot_data(value : SlotData) -> void:
	slot_data = value
	if slot_data == null:
		return
	if slot_data.item_data == null:
		print("FOEIDHZIOFUH")
		return
	texture_rect.texture = slot_data.item_data.texture
