class_name GameOver extends BaseLevel

@onready var final_score_label: Label = $CanvasLayer/VBoxContainer/HBoxContainer/FinalScoreLabel

func _ready() -> void:
	Inventory_Hud.hide()
	final_score_label.text = str(PlayerManager.INVENTORY_DATA.score)
