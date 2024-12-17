class_name GameManager extends Node

@export var lst_levels : Array[PackedScene]

var active_level : BaseLevel
var active_level_id : int
var can_player_loose := true
var first_attempt := true
@onready var sprite: TextureRect = $CanvasLayer/TransitionSprite

@onready var game_music: AudioStreamPlayer = $AudioStreamPlayer
@onready var intro_music: AudioStreamPlayer = $IntroMusic

func _ready() -> void:
	setup_screen()
	process_mode = PROCESS_MODE_ALWAYS
	#load_level(5)
	load_level(5)

func load_level(level_nb : int) -> void:
	if (!can_player_loose && level_nb == 2):
		return
		
	PlayerManager.can_die = false
	var new_level = lst_levels[level_nb].instantiate()
		
	var image = get_viewport().get_texture().get_image()
	var texture = ImageTexture.create_from_image(image)
	
	
	if (is_instance_valid(sprite)):
		sprite.texture = texture
			
		sprite.global_position = Vector2(0, 0)
		sprite.scale = Vector2(1, 1)
		sprite.modulate.a = 1.
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.5)
	
	if (active_level):
		get_tree().root.remove_child.call_deferred(active_level)
		PlayerManager.remove_player_from_scene()
	
	if (level_nb == 0):
		PlayerManager.add_player_to_scene(new_level)
		switch_music(intro_music, game_music, 4)
		
		
	get_tree().root.add_child.call_deferred(new_level)
	
	
	active_level = new_level
	PlayerManager.scene_id = level_nb
		
	if (level_nb == 0 && first_attempt):
		first_attempt = false
		new_level.tuto_entered = false

func switch_music(from : AudioStreamPlayer, to : AudioStreamPlayer, transition := 1.):
	to.play()
	to.volume_db = -80
	var fadein = get_tree().create_tween()
	fadein.tween_property(to, "volume_db", 0, transition)
	
	var fadeout = get_tree().create_tween()
	fadeout.tween_property(from, "volume_db", -80, transition)
	fadeout.tween_callback(from.stop)

func setup_screen():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	DisplayServer.window_set_size(Vector2i(1920,1080))
	
