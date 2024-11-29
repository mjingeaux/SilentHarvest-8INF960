class_name Controls extends BaseLevel

@onready var btn_retour: Button = $HBoxContainer/VBoxContainer/Container/btn_retour

func _ready() -> void:
	Inventory_Hud.hide()
	btn_retour.pressed.connect(return_to_start)
	
func return_to_start() -> void:
	get_node("/root/GameManager").load_level(3)
