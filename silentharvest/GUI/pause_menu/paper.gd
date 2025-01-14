class_name Paper extends CanvasLayer

signal shown

@onready var hover_sound: AudioStreamPlayer = $AudioStreamPlayer
@onready var pickup_sound: AudioStreamPlayer = $pickup
@onready var button: Button = $Control/Button

var is_paused : bool = false

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	resume_game()
	
func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("pause") or event.is_action_pressed("collect")) and \
		PlayerManager.scene_id == 0:
		if (is_paused):
			resume_game()
			get_viewport().set_input_as_handled()
			

func pause_game() -> void:
	get_tree().paused = true
	is_paused = true
	show()
	shown.emit()
	transition_in()
	AudioServer.set_bus_effect_enabled(1, 0, true)
	#btn_reprendre.grab_focus()

func resume_game() -> void:
	get_tree().paused = false
	is_paused = false
	hide()
	AudioServer.set_bus_effect_enabled(1, 0, false)


func _on_button_mouse_entered() -> void:
	hover_sound.play()


func _on_button_pressed() -> void:
	resume_game()
	
func transition_in():
	offset.y = 1000
	var t = get_tree().create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(self, "offset", Vector2.ZERO, 1.).set_trans(Tween.TRANS_QUAD)
	pickup_sound.play()
