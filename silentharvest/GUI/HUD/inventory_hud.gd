class_name InventoryHud extends CanvasLayer

@onready var inventory: InventoryUI = $InventoryBar/Inventory

func _ready() -> void:
	show()
