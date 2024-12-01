class_name StartMenu extends BaseLevel

@onready var btn_newgame: Button = $CanvasLayer/VBoxContainer/MenuOptions/Btn_newgame
@onready var btn_commandes: Button = $CanvasLayer/VBoxContainer/MenuOptions/Btn_commandes
@onready var btn_quitter: Button = $CanvasLayer/VBoxContainer/MenuOptions/Btn_quitter

func _ready() -> void:
	Inventory_Hud.hide()
	btn_newgame.pressed.connect(start_game)
	btn_commandes.pressed.connect(show_commands)
	btn_quitter.pressed.connect(quit_game)
	

func start_game() -> void:
	get_node("/root/GameManager").load_level(0)
	pass
	
func show_commands() -> void:
	get_node("/root/GameManager").load_level(4)
	pass

func quit_game() -> void:
	get_tree().quit()
