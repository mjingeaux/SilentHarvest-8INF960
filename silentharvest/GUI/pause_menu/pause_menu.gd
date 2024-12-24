class_name PauseMenu extends CanvasLayer

signal shown
signal hidden

@onready var scorelabel: Label = $HBoxContainer/ScoreLabel
@onready var hover_sound: AudioStreamPlayer = $AudioStreamPlayer
@onready var btn_reprendre: Button = $GridContainer/Btn_Reprendre

var is_paused : bool = false

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	shown.connect(update_score_label)
	resume_game()
	
func pause_game() -> void:
	get_tree().paused = true
	is_paused = true
	show()
	shown.emit()
	AudioServer.set_bus_effect_enabled(1, 0, true)
	btn_reprendre.grab_focus()

func resume_game() -> void:
	get_tree().paused = false
	is_paused = false
	hide()
	hidden.emit()
	AudioServer.set_bus_effect_enabled(1, 0, false)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and PlayerManager.scene_id == 0:
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

func update_score_label() -> void:
	scorelabel.text = str(PlayerManager.INVENTORY_DATA.score)


func _on_btn_reprendre_mouse_entered() -> void:
	hover_sound.play()

func _on_btn_quitter_mouse_entered() -> void:
	hover_sound.play()
