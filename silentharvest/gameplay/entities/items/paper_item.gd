class_name PaperItem extends Node2D 

@onready var area_2d : Area2D = $Area2D

var is_player_in_area : bool = false

func _input(event : InputEvent) -> void:
	if is_player_in_area and event.is_action_pressed("collect"):
		get_viewport().set_input_as_handled()
		Paper_hud.pause_game()
		

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		is_player_in_area = true
		Pickup_Key.show()



func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		is_player_in_area = false
		Pickup_Key.hide()
