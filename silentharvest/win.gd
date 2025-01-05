class_name GameOver extends BaseLevel

@onready var final_score_label: Label = $CanvasLayer/VBoxContainer/HBoxContainer/FinalScoreLabel
@onready var btn_recommencer: Button = $CanvasLayer/VBoxContainer2/Btn_Recommencer
@onready var btn_quitter: Button = $CanvasLayer/VBoxContainer2/Btn_Quitter
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	Inventory_Hud.hide()
	final_score_label.text = str(PlayerManager.INVENTORY_DATA.score + 20)
	btn_recommencer.pressed.connect(_on_recommencer_pressed)
	btn_quitter.pressed.connect(_on_quitter_pressed)
	btn_recommencer.grab_focus()
	
func _on_recommencer_pressed() -> void:
	get_node("/root/GameManager").load_level(0)

func _on_quitter_pressed() -> void:
	get_tree().quit()


func _on_btn_recommencer_mouse_entered() -> void:
	audio_stream_player.play()

func _on_btn_quitter_mouse_entered() -> void:
	audio_stream_player.play()
