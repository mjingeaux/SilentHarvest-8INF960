class_name Enemy extends CharacterBody2D

signal direction_changed( _new_direction : Vector2)
signal poi_finished()

signal entering_patrol()
signal exiting_patrol()

var player : Player

const DIR_4 = [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP]
var cardinal_direction : Vector2 = Vector2.DOWN
var _last_pos : Vector2



@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D 
@onready var state_machine : EnemyStateMachine = $EnemyStateMachine
@onready var vision_area : VisionArea = $VisionArea
@onready var animation_tree : AnimationTree = $AnimationTree

var first_state_entering := true
var char_direction : Vector2 = Vector2.ZERO

func _ready():
	state_machine.initialize(self)
	_last_pos = global_position

func _process(delta):
	update_animation_parameters()


func _physics_process(delta: float) -> void:
	char_direction = velocity.normalized()
	move_and_slide()
	

#func set_direction(_new_direction : Vector2) -> bool:
	#direction = _new_direction
	#if direction == Vector2.ZERO:
		#return false
	#var direction_id : int = int(round((direction + cardinal_direction * 0.1).angle()/TAU*DIR_4.size()))
	#var new_dir = DIR_4[direction_id]
	#if new_dir == cardinal_direction:
		#return false
	#
	#cardinal_direction = new_dir
	#direction_changed.emit(new_dir)
	#sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	#return true

func match_direction_to_displacement():
	if (global_position != _last_pos):
		var direction = rad_to_deg((global_position - _last_pos).angle())
		_last_pos = global_position
		set_direction(direction)
	
func set_direction(angle_degree : float):
	if (!vision_area):
		return
	vision_area.angle_target_degree = angle_degree
	
func update_animation_parameters():
	if(velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/is_resting"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/is_resting"] = false
		animation_tree["parameters/conditions/is_moving"] = true

	if(velocity != Vector2.ZERO):
		animation_tree["parameters/Chase/blend_position"] = char_direction
		animation_tree["parameters/Idle/blend_position"] = char_direction

func update_animation(state : String) -> void:
	if state == "chase":
		var exclamation = preload("res://gameplay/entities/enemies/ExclamationMark.tscn").instantiate()
		add_child(exclamation)
		await get_tree().create_timer(0.5).timeout
		remove_child(exclamation)
	#animation_player.play(state+"_"+anim_direction())

func _on_idle_state_exited() -> void:
	exiting_patrol.emit()

func _on_idle_state_entered() -> void:
	if (first_state_entering):
		first_state_entering = false
		return
	entering_patrol.emit()

func anim_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"
		

func play_poi(poi_id : GlobalE.Epoi_type):
	match poi_id:
		GlobalE.Epoi_type.wait_short:
			await get_tree().create_timer(.5).timeout
		GlobalE.Epoi_type.wait_long:
			await get_tree().create_timer(1.5).timeout
			
		GlobalE.Epoi_type.right_then_left_narrow:
			vision_area.angle_target_degree += 30
			await vision_area.rotation_completed
			await get_tree().create_timer(.3).timeout
			vision_area.angle_target_degree -= 60
			await vision_area.rotation_completed
			await get_tree().create_timer(.3).timeout
			
		GlobalE.Epoi_type.right_then_left_wide:
			vision_area.angle_target_degree += 65
			await vision_area.rotation_completed
			await get_tree().create_timer(.3).timeout
			vision_area.angle_target_degree -= 130
			await vision_area.rotation_completed
			await get_tree().create_timer(.3).timeout
			
		GlobalE.Epoi_type.left_then_right_narrow:
			vision_area.angle_target_degree -= 30
			await vision_area.rotation_completed
			await get_tree().create_timer(.3).timeout
			vision_area.angle_target_degree += 60
			await vision_area.rotation_completed
			await get_tree().create_timer(.3).timeout
			
		GlobalE.Epoi_type.left_then_right_wide:
			vision_area.angle_target_degree -= 65
			await vision_area.rotation_completed
			await get_tree().create_timer(.3).timeout
			vision_area.angle_target_degree += 130
			await vision_area.rotation_completed
			await get_tree().create_timer(.3).timeout
			
		GlobalE.Epoi_type.left_trick:
			vision_area.rotation_speed = vision_area.Erotation_speed.slow
			vision_area.angle_target_degree -= 30
			await vision_area.rotation_completed
			await get_tree().create_timer(.15).timeout
			vision_area.rotation_speed = vision_area.Erotation_speed.default
			vision_area.angle_target_degree += 20
			await vision_area.rotation_completed
			vision_area.rotation_speed = vision_area.Erotation_speed.fast
			vision_area.angle_target_degree -= 60
			await vision_area.rotation_completed
			vision_area.rotation_speed = vision_area.Erotation_speed.default
			await get_tree().create_timer(.7).timeout
			
		GlobalE.Epoi_type.right_trick:
			vision_area.rotation_speed = vision_area.Erotation_speed.slow
			vision_area.angle_target_degree += 30
			await vision_area.rotation_completed
			await get_tree().create_timer(.15).timeout
			vision_area.rotation_speed = vision_area.Erotation_speed.default
			vision_area.angle_target_degree -= 20
			await vision_area.rotation_completed
			vision_area.rotation_speed = vision_area.Erotation_speed.fast
			vision_area.angle_target_degree += 60
			await vision_area.rotation_completed
			vision_area.rotation_speed = vision_area.Erotation_speed.default
			await get_tree().create_timer(.7).timeout
			
		GlobalE.Epoi_type.cw_full_turn:
			for i in range(3):
				vision_area.angle_target_degree += 120
				await vision_area.rotation_completed
			await get_tree().create_timer(.3).timeout
			
		GlobalE.Epoi_type.ccw_full_turn:
			for i in range(3):
				vision_area.angle_target_degree -= 120
				await vision_area.rotation_completed
			await get_tree().create_timer(.3).timeout
	poi_finished.emit()

#func _wait(sec : float):
