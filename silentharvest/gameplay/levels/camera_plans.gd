class_name CameraPlan extends Area2D

const ZOOM_IN := Vector2(3, 3)

var width_target := -1.
var height_target := -1.

var pos_target : Vector2
var zoom_target : Vector2
var transition_in := false
var transition_out := false
var follow_rail := false

var transition_timer := 0.
var transition_duration := 1.
var transition_start_position : Vector2
var transition_start_zoom : Vector2

var is_fixed_point := true

var camera : Camera2D

@export var should_unzoom := false
@export var rail : Line2D
@export var ZOOM_OUT := Vector2(2.5, 2.5)
@export var rail_offset := Vector2(0, 0)
var fixed_point : Vector2



func _ready() -> void:
	PlayerManager.player_caught.connect(_on_player_caught)
	
	if (is_instance_valid(rail)):
		is_fixed_point = false
		if (rail.transform != Transform2D.IDENTITY):
			printerr("Warning, camera rail has a transform. It means it will not behave as designed")
			breakpoint
	else:
		for node in get_children():
			if (node is Marker2D):
				is_fixed_point = true
				fixed_point = node.global_position
				break
				
func _on_player_caught() -> void:
	if (is_instance_valid(camera)):
		camera.reparent(PlayerManager.player)
		
func tween_position():
	return Tween.interpolate_value(
				transition_start_position,
				pos_target - transition_start_position,
				transition_timer,
				transition_duration,
				Tween.TRANS_QUINT,
				Tween.EASE_OUT )
				
func tween_zoom():
	return Tween.interpolate_value(
		transition_start_zoom,
		zoom_target - transition_start_zoom,
		transition_timer,
		transition_duration,
		Tween.TRANS_QUINT,
		Tween.EASE_OUT
	)

func _process(delta: float) -> void:
	var player_pos := PlayerManager.player.global_position
	
	if (transition_in || transition_out):
		if (transition_out):
			pos_target = player_pos
		else:
			if (!is_fixed_point):
				pos_target = get_point_on_rail(player_pos)
			
		transition_timer += delta
		camera.global_position = tween_position()
		if (should_unzoom):
			camera.zoom = tween_zoom()
	else:
		if (!is_fixed_point && follow_rail):
			camera.global_position = get_point_on_rail(player_pos)
		
			
	if (transition_timer > transition_duration):
		transition_timer = 0
		transition_in = false
		transition_out = false
		


func _on_body_entered(body: Node2D) -> void:
	if (body is Player):
		camera = body.camera_2d
		if (transition_out):
			transition_timer = 0

		transition_in = true
		transition_out = false
		camera.reparent(self)
		
		if (is_fixed_point):
			pos_target = fixed_point
		else:
			pos_target = get_point_on_rail(body.global_position)
			follow_rail = true
				
		transition_start_position = camera.global_position
		if (should_unzoom):
			zoom_target = ZOOM_OUT
			transition_start_zoom = camera.zoom

func _on_body_exited(body: Node2D) -> void:
	if (is_instance_valid(camera)):
		if (body is Player):
			if (transition_in):
				transition_timer = 0
			transition_in = false
			transition_out = true
			camera.reparent(PlayerManager.player)
			follow_rail = false
			pos_target = PlayerManager.player.position
			transition_start_position = camera.global_position
			transition_start_zoom = camera.zoom
			zoom_target = ZOOM_IN
			

#specified function
func get_point_on_rail(pos : Vector2):
	return get_closest_point_on_aal(pos, (rail.points[0]), (rail.points[1])) + rail_offset

#general function		
func get_closest_point_on_aal(projetee : Vector2, line_p1 : Vector2, line_p2: Vector2) -> Vector2:
	#tests which axis the line is the nearest
	var delta_x = line_p2.x - line_p1.x
	var delta_y = line_p2.y - line_p1.y
	if (abs(delta_x) < abs(delta_y)):
		#line is vertical-ish
		var min_y = minf(line_p1.y, line_p2.y)
		var max_y = maxf(line_p1.y, line_p2.y)
		return Vector2(line_p1.x + delta_x / 2, clampf(projetee.y, min_y, max_y))
	else:
		#line is horizontal-ish
		var min_x = minf(line_p1.x, line_p2.x)
		var max_x = maxf(line_p1.x, line_p2.x)
		return Vector2(clampf(projetee.x, min_x, max_x), line_p1.y + delta_y / 2)
	
	
