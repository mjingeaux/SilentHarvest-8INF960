class_name Enemy extends CharacterBody2D

signal direction_changed( _new_direction : Vector2)
signal poi_finished()

signal entering_patrol()
signal exiting_patrol()

var suspicion_jauge := 0. : set = _set_suspicion_jauge
@export var reset_after_full_value := .3
@export_range(0., 1., .1) var noise_sensibility := .5
#time in seconds it would need to decrease suspicion from 1 to 0
@export_range(.1, 10., .1) var suspicion_decay_time := 4.

const DIR_4 = [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP]
var cardinal_direction : Vector2 = Vector2.DOWN #TODO to delete

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D 
@onready var state_machine : EnemyStateMachine = $EnemyStateMachine
@onready var vision_area : VisionArea = $VisionArea
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var sus_timer : Timer = $SuspicionTimer
@onready var goto_inspect_state : EnemyStateGoto = $EnemyStateMachine/GotoInspect

@onready var label : Label = $Label

var is_listening_noise := true
var patrol_restart_pos : Vector2

var _first_state_entering := true
var _is_suspicion_decaying := false
var _lst_suspicious_point : Array[Vector2]


func _ready():
	state_machine.initialize(self)
	sus_timer.timeout.connect(func () : _is_suspicion_decaying = true)
	
	goto_inspect_state.state_exited.connect(func (): _lst_suspicious_point.pop_front())

func _process(delta):
	update_animation_parameters()
	if (_is_suspicion_decaying):
		suspicion_jauge -= delta / suspicion_decay_time


func _physics_process(delta: float) -> void:
	move_and_slide()
	

func match_direction_to_displacement():
	if (velocity != Vector2.ZERO):
		var direction = rad_to_deg(velocity.angle())
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

		animation_tree["parameters/Chase/blend_position"] = velocity
		animation_tree["parameters/Idle/blend_position"] = velocity

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
	if (_first_state_entering):
		_first_state_entering = false
		return
	entering_patrol.emit()
	
func _set_suspicion_jauge(val : float):
	if (val > suspicion_jauge):
		_is_suspicion_decaying = false
		sus_timer.stop()
		sus_timer.start()
	
	if (val < 0.):
		suspicion_jauge = 0.
		_is_suspicion_decaying = false
	elif (val >= 1.):
		suspicion_jauge = .3
		add_suspicious_point( PlayerManager.player.global_position)
	else:
		suspicion_jauge = val
	label.text = str(suspicion_jauge)
	
func add_suspicious_point(global_pos : Vector2):
	var inserted = false
	var dist = (global_position - global_pos).length()
	for i in range(_lst_suspicious_point.size()):
		var dist2 = (global_position - _lst_suspicious_point[i]).length()
		if (dist < dist2):
			_lst_suspicious_point.insert(i, global_pos)
			inserted = true
			break
	if (!inserted):
		_lst_suspicious_point.append(global_pos)
	
	if (_lst_suspicious_point[0] == global_pos):
		goto_inspect_state.goto(global_pos)

func hear_noise(intensity : float, delta : float):
	if (is_listening_noise):
		suspicion_jauge += intensity * delta

func play_poi(poi_id : GlobalE.Epoi_type):
	velocity = Vector2.ZERO
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
