class_name StartMenu extends BaseLevel

@onready var sound_hover: AudioStreamPlayer = $AudioStreamPlayer
@onready var btn_newgame: Button = $CanvasLayer/MenuOptions/Btn_newgame
@onready var btn_commandes: Button = $CanvasLayer/MenuOptions/Btn_commandes
@onready var btn_quitter: Button = $CanvasLayer/MenuOptions/Btn_quitter
@onready var menu_options: VBoxContainer = $CanvasLayer/MenuOptions
@onready var title: TextureRect = $CanvasLayer2/Title
@onready var title_timer: Timer = $TitleTimer
@onready var menu_timer: Timer = $MenuTimer

@onready var cicada: AudioStreamPlayer = $cicada
@onready var raven: AudioStreamPlayer = $raven

var title_fading_in = false
var menu_fading_in = false
var fade_in_duration = 2.0
var title_elapsed_time = 0.0
var menu_elapsed_time = 0.0

func _ready() -> void:
	Inventory_Hud.hide()
	
	var fadein = get_tree().create_tween()
	fadein.tween_property(cicada, "volume_db", -12, 4)

	btn_newgame.pressed.connect(start_game)
	btn_commandes.pressed.connect(show_commands)
	btn_quitter.pressed.connect(quit_game)
	if PlayerManager.is_first_time_start:
		raven.play()
		PlayerManager.is_first_time_start = false
		title.modulate.a = 0
		menu_options.modulate.a = 0
		title_timer.timeout.connect(_on_title_timer_timeout)
		menu_timer.timeout.connect(_on_menu_timer_timeout)
		title_timer.start()
		menu_timer.start()

func _on_title_timer_timeout() -> void:
	title_fading_in = true
	btn_newgame.grab_focus()
	

func _on_menu_timer_timeout() -> void:
	menu_fading_in = true
	
	
func _process(delta: float) -> void:
	if title_fading_in:
		title_elapsed_time += delta
		var alpha = clamp(title_elapsed_time / fade_in_duration,0.0,1.0)
		title.modulate.a = alpha
		if alpha == 1.0 : 
			title_fading_in = false
	if menu_fading_in:
		menu_elapsed_time += delta
		var alpha = clamp(menu_elapsed_time / fade_in_duration,0.0,1.0)
		menu_options.modulate.a = alpha
		if alpha == 1.0 : 
			title_fading_in = false

func start_game() -> void:
	get_node("/root/GameManager").load_level(0)
	pass
	
func show_commands() -> void:
	get_node("/root/GameManager").load_level(4)
	pass

func quit_game() -> void:
	get_tree().quit()


func _on_btn_newgame_mouse_entered() -> void:
	sound_hover.play()

func _on_btn_commandes_mouse_entered() -> void:
	sound_hover.play()

func _on_btn_quitter_mouse_entered() -> void:
	sound_hover.play()
