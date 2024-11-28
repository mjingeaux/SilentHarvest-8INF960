class_name Level_1 extends BaseLevel

func _ready() -> void:
	PlayerManager.clear_inventory()
	Inventory_Hud.show()
