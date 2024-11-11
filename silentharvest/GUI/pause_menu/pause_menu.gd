class_name PauseMenu extends CanvasLayer

signal shown
signal hidden

@onready var inventory: InventoryUI = $PanelContainer/Inventory

var is_paused : bool = false

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	shown.connect(inventory.update_inventory)
	hidden.connect(inventory.clear_inventory)
	resume_game()
	
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
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused:
			resume_game()
		else:
			pause_game()
	get_viewport().set_input_as_handled()

func _on_btn_reprendre_pressed() -> void:
	resume_game()
	pass # Replace with function body.


func _on_btn_quitter_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
