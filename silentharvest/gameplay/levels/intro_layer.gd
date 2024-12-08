extends CanvasLayer

@onready var sprite: TextureRect = $TextureRect
@onready var timer: Timer = $Timer

var images = [preload("res://Assets/intro/frame1.png"), preload("res://Assets/intro/frame2.jpg"),
 preload("res://Assets/intro/frame3.jpg")]
var current_index = 0
var zoom_speed = 0.01
var max_scale = Vector2(1.2, 1.2)
var is_zooming = true

func _ready():
	Inventory_Hud.hide()
	sprite.texture = images[current_index]
	sprite.scale = Vector2(1, 1)
	timer.timeout.connect(_on_Timer_timeout)
	timer.start()

func _process(delta):
	if is_zooming:
		sprite.scale += Vector2(zoom_speed, zoom_speed) * delta

func _on_Timer_timeout():
	is_zooming = false
	current_index += 1
	if current_index < images.size():
		print("NEXT FRAME PLS")
		sprite.texture = images[current_index]
		sprite.scale = Vector2(1, 1)
		is_zooming = true
	else:
		await get_tree().create_timer(1.0).timeout
		get_node("/root/GameManager").load_level(3)
		
func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("pause")):
		get_node("/root/GameManager").load_level(3)

func _go_to_next_scene():
	get_tree().change_scene("res://next_scene.tscn")
