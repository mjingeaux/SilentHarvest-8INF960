class_name CameraPlan extends Area2D

var width_target := -1.
var height_target := -1.

var pos_target : Vector2
var transition_in := false
var transition_out := false

var transition_timer := 0.
var transition_duration := 1.
var transition_start : Vector2

var camera : Camera2D

@export var offset := Vector2(0, 0)
@export var invert_one_way := false



func _ready() -> void:
	PlayerManager.player_caught.connect(_on_player_caught)
	
func _on_player_caught() -> void:
	if (is_instance_valid(camera)):
		camera.reparent(PlayerManager.player)
		
func tween():
	return Tween.interpolate_value(
				transition_start,
				pos_target - transition_start,
				transition_timer,
				transition_duration,
				Tween.TRANS_QUINT,
				Tween.EASE_OUT )
	

func _process(delta: float) -> void:
	if (transition_in || transition_out):
		#camera.global_position = camera.global_position * .96 + pos_target * .04
		if (transition_out):
			pos_target = PlayerManager.player.global_position
		transition_timer += delta
		camera.global_position = tween()
		

			
			
		#if (abs(camera.global_position - pos_target) < Vector2(.3, .3)):
			#transition_in = false
			#camera.global_position = pos_target
	#if (transition_out):
		#
		#transition_timer += delta
		#camera.global_position = tween()
		#camera.global_position = camera.global_position * .96 + PlayerManager.player.global_position * .04
		#if (abs(camera.global_position - pos_target) < Vector2(.3, .3)):
			#transition_out = false
			#camera.global_position = PlayerManager.player.global_position
			#camera = null
			
	if (transition_timer > transition_duration):
		transition_timer = 0
		transition_in = false
		transition_out = false



func _on_body_entered(body: Node2D) -> void:
			
	if (body is Player):
		
		if (offset != Vector2.ZERO):
			var area_direction = offset.normalized().snappedf(1.)
			if (invert_one_way):
				area_direction = -area_direction
			
			var body_direction = body.velocity.normalized().snappedf(1.)
			if 	(area_direction.x == 0 && body_direction.y == -area_direction.y) ||	(
				area_direction.y == 0 && body_direction.x == -area_direction.x):
				return
				
		camera = body.camera_2d
		var collision_shape : CollisionShape2D = get_child(0)
		var shape = collision_shape.shape
		if (shape is RectangleShape2D):
			if (transition_out):
				transition_timer = 0

			transition_in = true
			transition_out = false
			camera.reparent(self)
			var size = shape.size
			pos_target = collision_shape.global_position + offset
			transition_start = camera.global_position
			var zoom_t = get_tree().create_tween()
			zoom_t.tween_property(camera, "zoom", Vector2(2, 2), 1)
			#if (size.x >= size.y):
				#width_target = size.x
				#height_target = -1.
			#else:
				#width_target = -1.
				#height_target = size.y

func _on_body_exited(body: Node2D) -> void:
	if (is_instance_valid(camera)):
		if (body is Player):
			if (transition_in):
				transition_timer = 0
			transition_in = false
			transition_out = true
			camera.reparent(PlayerManager.player)
			pos_target = PlayerManager.player.position
			transition_start = camera.global_position
		
