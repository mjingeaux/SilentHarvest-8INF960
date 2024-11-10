class_name GameManager extends Node

@export var lst_levels : Array[PackedScene]

var active_level : BaseLevel

func _ready() -> void:
	setup_screen()
	process_mode = PROCESS_MODE_ALWAYS
	load_level(0)

func load_level(level_nb : int) -> void:
	active_level = lst_levels[level_nb].instantiate()
	PlayerManager.add_player_to_scene(active_level)
	get_tree().root.add_child.call_deferred(active_level)


func setup_screen():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_size(Vector2i(1920,1080))
