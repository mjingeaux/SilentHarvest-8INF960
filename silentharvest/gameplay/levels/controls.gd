class_name Controls extends BaseLevel

@onready var btn_retour: Button = $HBoxContainer/VBoxContainer/Container/btn_retour
@onready var sound_hover: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	Inventory_Hud.hide()
	btn_retour.pressed.connect(return_to_start)
	
func return_to_start() -> void:
	get_node("/root/GameManager").load_level(3)


func _on_btn_retour_mouse_entered() -> void:
	sound_hover.play()
