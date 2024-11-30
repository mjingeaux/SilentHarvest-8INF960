class_name GameManager extends Node

@export var lst_levels : Array[PackedScene]

var active_level : BaseLevel
var can_player_loose := true
@onready var transition_sprite: Sprite2D = $TransitionSprite
@onready var music: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	setup_screen()
	process_mode = PROCESS_MODE_ALWAYS
	load_level(0)

func load_level(level_nb : int) -> void:
	if (!can_player_loose && level_nb == 2):
		return
		
	PlayerManager.can_die = false
	var new_level = lst_levels[level_nb].instantiate()
		
	var image = get_viewport().get_texture().get_image()
	var texture = ImageTexture.create_from_image(image)
	var sprite : Sprite2D = transition_sprite
	
	if (is_instance_valid(sprite)):
		sprite.texture = texture
		if (level_nb == 0):
			sprite.global_position = Vector2.ZERO
			sprite.scale = Vector2(1./3., 1./3.)
		else:
			sprite.global_position = texture.get_size() / 2.
			sprite.scale = Vector2(1, 1)
		sprite.modulate.a = 1.
		var tween = get_tree().create_tween()
		tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 1)
	
	#tween.tween_callback($Sprite.queue_free)
		
	if (active_level):
		get_tree().root.remove_child.call_deferred(active_level)
		PlayerManager.remove_player_from_scene()
	
	if (level_nb != 2):
		PlayerManager.add_player_to_scene(new_level)
	get_tree().root.add_child.call_deferred(new_level)
	active_level = new_level
	
	
	
		


func setup_screen():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	DisplayServer.window_set_size(Vector2i(1920,1080))
