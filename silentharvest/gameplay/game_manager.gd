class_name GameManager extends Node

@export var lst_levels : Array[PackedScene]

var active_level : BaseLevel
var active_level_id : int
var can_player_loose := true

func _ready() -> void:
	setup_screen()
	process_mode = PROCESS_MODE_ALWAYS
	load_level(3)

func load_level(level_nb : int) -> void:
	if (!can_player_loose && level_nb == 2):
		return
	
	var new_level = lst_levels[level_nb].instantiate()
	if (active_level):
		get_tree().root.remove_child.call_deferred(active_level)
		PlayerManager.remove_player_from_scene()
	
	if (level_nb == 0):
		PlayerManager.add_player_to_scene(new_level)
	get_tree().root.add_child.call_deferred(new_level)
	active_level = new_level
	PlayerManager.scene_id = level_nb
	


func setup_screen():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	DisplayServer.window_set_size(Vector2i(1920,1080))
