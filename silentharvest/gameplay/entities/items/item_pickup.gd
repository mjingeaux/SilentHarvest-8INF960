class_name ItemPickup extends Node2D 

@export var item_data : ItemData : set = _set_item_data
@onready var area_2d : Area2D = $Area2D
@onready var sprite_2d : Sprite2D = $Sprite2D
@onready var audio_player_2d : AudioStreamPlayer2D = $AudioStreamPlayer2D

var is_player_in_area : bool = false

func _input(event) -> void:
	if is_player_in_area and event.is_action_pressed("collect"):
		if item_data:
			print(item_data.name)
			PlayerManager.INVENTORY_DATA.add_item(item_data)
			item_picked_up()
	pass

func _ready() -> void:
	_update_texture()
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)
		
func _on_body_entered(b) -> void:
	if b is Player:
		Pickup_Key.show()
		is_player_in_area = true
	pass

func _on_body_exited(b) -> void:
	if b is Player:
		Pickup_Key.hide()
		is_player_in_area = false
		
func item_picked_up() -> void:
	area_2d.body_entered.disconnect(_on_body_entered)
	audio_player_2d.play()
	visible = false
	await audio_player_2d.finished
	queue_free()
	pass
	
func _set_item_data(value : ItemData) -> void:
	item_data = value
	_update_texture()
	pass

func _update_texture() -> void:
	if item_data and sprite_2d:
		sprite_2d.texture = item_data.texture
		
	pass
