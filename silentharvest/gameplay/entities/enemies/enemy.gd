class_name Enemy extends CharacterBody2D

signal poi_finished()
signal inspect_finished()

signal entering_patrol()
signal exiting_patrol()

var suspicion_jauge := 0. : set = _set_suspicion_jauge
@export var reset_after_full_value := .3
@export_range(0., 1., .1) var noise_sensibility := .5
#time in seconds it would need to decrease suspicion from 1 to 0
@export_range(.1, 10., .1) var suspicion_decay_time := 2.6

@export var min_jauge_color : Color = Color("da863e")
@export var max_jauge_color : Color = Color("a53030")

@export var base_direction := Vector2(1, 0)

const DIR_4 = [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP]
var cardinal_direction : Vector2 = Vector2.DOWN #TODO to delete

# indicates how many tall grass area the enemy is colliding with
# used as a c style boolean
var tall_grass_counter := 0 

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D 
@onready var state_machine : EnemyStateMachine = $EnemyStateMachine
@onready var vision_area : VisionArea = $VisionArea
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var expression_player: AnimationPlayer = $ExpressionPlayer
@onready var sus_timer : Timer = $SuspicionTimer
@onready var poi_timer: Timer = $PoiTimer
@onready var goto_inspect_state : EnemyStateGoto = $EnemyStateMachine/GotoInspect
@onready var progress_bar : TextureProgressBar = $JaugeScaler/ProgressBar
@onready var jauge_scaler: Node2D = $JaugeScaler
@onready var inspect_timer: Timer = $EnemyStateMachine/Inspect/InspectTimer
@onready var footsteps: AudioStreamPlayer2D = $footsteps

var is_listening_noise := true
var patrol_restart_pos : Vector2

var _first_state_entering := true
var _is_suspicion_decaying := false
var lst_suspicious_point : Array[Vector2]


func _ready():
	state_machine.initialize(self)
	sus_timer.timeout.connect(func () : _is_suspicion_decaying = true)
	
	goto_inspect_state.state_exited.connect(func (): lst_suspicious_point.pop_front())
	var nav_agent = $NavigationAgent
	$EnemyStateMachine/Chase.navigation_agent = nav_agent
	$EnemyStateMachine/GotoPatrol.navigation_agent = nav_agent
	$EnemyStateMachine/GotoInspect.navigation_agent = nav_agent
	$"lost".visible = false
	$"found".visible = false
	
	set_defualt_direction()
	
	
func _process(delta):
	update_animation_parameters()
	if (_is_suspicion_decaying):
		suspicion_jauge -= delta / suspicion_decay_time


func _physics_process(_delta: float) -> void:
	move_and_slide()
	

func match_direction_to_displacement():
	if (velocity != Vector2.ZERO):
		var direction = rad_to_deg(velocity.angle())
		set_direction(direction)
	
func set_direction(angle_degree : float):
	if (!vision_area):
		return
	vision_area.angle_target_degree = angle_degree
	
func set_defualt_direction():
	animation_tree["parameters/Idle/blend_position"] = base_direction
	set_direction(rad_to_deg(base_direction.angle()))
	
func update_animation_parameters():
	if(velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/is_resting"] = true
		animation_tree["parameters/conditions/is_moving"] = false
		footsteps.stop()
	else:
		animation_tree["parameters/conditions/is_resting"] = false
		animation_tree["parameters/conditions/is_moving"] = true

		animation_tree["parameters/Chase/blend_position"] = velocity
		animation_tree["parameters/Idle/blend_position"] = velocity
		if (!footsteps.playing):
			footsteps.play()

func update_animation(anim : String, activate : bool) -> void:
	if (activate):
		if (anim == "?"):
			expression_player.play("in?")
		elif (anim == "!"):
			expression_player.play("in!")
	else:
		if (anim == "?"):
			$lost.visible = false
		elif (anim == "!"):
			$found.visible = false
		
		
func _on_idle_state_exited() -> void:
	exiting_patrol.emit()

func _on_idle_state_entered() -> void:
	if (_first_state_entering):
		_first_state_entering = false
		return
	entering_patrol.emit()
	
func _on_inspect_state_exited() -> void:
	inspect_next_point()
	
func inspect_next_point():
	if (lst_suspicious_point.is_empty()):
		return false
	goto_inspect_state.goto(lst_suspicious_point[0])
	return true
	
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
	progress_bar.value = suspicion_jauge
	progress_bar.tint_progress = min_jauge_color.lerp(max_jauge_color, progress_bar.value * 2 - .5)
	var scaling = 1 + progress_bar.value * .5
	jauge_scaler.scale = Vector2(scaling, scaling)

	
func add_suspicious_point(global_pos : Vector2):
	var inserted = false
	var dist = (global_position - global_pos).length()
	for i in range(lst_suspicious_point.size()):
		var dist2 = (global_position - lst_suspicious_point[i]).length()
		if (dist < dist2):
			lst_suspicious_point.insert(i, global_pos)
			inserted = true
			break
	if (!inserted):
		lst_suspicious_point.append(global_pos)
	
	if (lst_suspicious_point[0] == global_pos):
		goto_inspect_state.goto(global_pos)
		goto_inspect_state.enter()


func hear_noise(intensity : float, delta : float):
	if (is_listening_noise):
		suspicion_jauge += intensity * delta * (noise_sensibility + .5)

func play_poi(poi_id : GlobalE.Epoi_type):
	velocity = Vector2.ZERO
	match poi_id:
		GlobalE.Epoi_type.wait_short:
			
			poi_timer.start(.5)
			await poi_timer.timeout
		GlobalE.Epoi_type.wait_long:
			poi_timer.start(1.5)
			await poi_timer.timeout
			
			
		GlobalE.Epoi_type.right_then_left_narrow:
			vision_area.angle_target_degree += 30
			await vision_area.rotation_completed
			poi_timer.start(.3)
			await poi_timer.timeout
			
			vision_area.angle_target_degree -= 60
			await vision_area.rotation_completed
			poi_timer.start(.3)
			await poi_timer.timeout
			
			
		GlobalE.Epoi_type.right_then_left_wide:
			vision_area.angle_target_degree += 65
			await vision_area.rotation_completed
			poi_timer.start(.3)
			await poi_timer.timeout
			vision_area.angle_target_degree -= 130
			await vision_area.rotation_completed
			poi_timer.start(.3)
			await poi_timer.timeout
			
		GlobalE.Epoi_type.left_then_right_narrow:
			vision_area.angle_target_degree -= 30
			await vision_area.rotation_completed
			poi_timer.start(.3)
			await poi_timer.timeout
			vision_area.angle_target_degree += 60
			await vision_area.rotation_completed
			poi_timer.start(.3)
			await poi_timer.timeout
			
		GlobalE.Epoi_type.left_then_right_wide:
			vision_area.angle_target_degree -= 65
			await vision_area.rotation_completed
			poi_timer.start(.3)
			await poi_timer.timeout
			vision_area.angle_target_degree += 130
			await vision_area.rotation_completed
			poi_timer.start(.3)
			await poi_timer.timeout
			
		GlobalE.Epoi_type.left_trick:
			vision_area.rotation_speed = vision_area.Erotation_speed.slow
			vision_area.angle_target_degree -= 30
			await vision_area.rotation_completed
			poi_timer.start(.15)
			await poi_timer.timeout
			vision_area.rotation_speed = vision_area.Erotation_speed.default
			vision_area.angle_target_degree += 20
			await vision_area.rotation_completed
			vision_area.rotation_speed = vision_area.Erotation_speed.fast
			vision_area.angle_target_degree -= 60
			await vision_area.rotation_completed
			vision_area.rotation_speed = vision_area.Erotation_speed.default
			poi_timer.start(.7)
			await poi_timer.timeout
			
		GlobalE.Epoi_type.right_trick:
			vision_area.rotation_speed = vision_area.Erotation_speed.slow
			vision_area.angle_target_degree += 30
			await vision_area.rotation_completed
			poi_timer.start(.15)
			await poi_timer.timeout
			vision_area.rotation_speed = vision_area.Erotation_speed.default
			vision_area.angle_target_degree -= 20
			await vision_area.rotation_completed
			vision_area.rotation_speed = vision_area.Erotation_speed.fast
			vision_area.angle_target_degree += 60
			await vision_area.rotation_completed
			vision_area.rotation_speed = vision_area.Erotation_speed.default
			poi_timer.start(.7)
			await poi_timer.timeout
			
		GlobalE.Epoi_type.cw_full_turn:
			vision_area.rotation_speed = vision_area.Erotation_speed.very_slow
			for i in range(3):
				vision_area.angle_target_degree += 120
				await vision_area.rotation_completed
			vision_area.rotation_speed = vision_area.Erotation_speed.default
			poi_timer.start(.3)
			await poi_timer.timeout
			
			
		GlobalE.Epoi_type.ccw_full_turn:
			vision_area.rotation_speed = vision_area.Erotation_speed.very_slow
			for i in range(3):
				vision_area.angle_target_degree -= 120
				await vision_area.rotation_completed
			vision_area.rotation_speed = vision_area.Erotation_speed.default
			poi_timer.start(.3)
			await poi_timer.timeout
			
	#avoid rotation only poi not to get paused when changing state
	poi_timer.start(.1)
	await poi_timer.timeout
	poi_finished.emit()


func play_poi_inspect():
	velocity = Vector2.ZERO
	vision_area.angle_target_degree += 65
	await vision_area.rotation_completed
	inspect_timer.start(.3)
	await inspect_timer.timeout
	vision_area.angle_target_degree -= 130
	await vision_area.rotation_completed
	inspect_timer.start(.3)
	await inspect_timer.timeout
	inspect_finished.emit()
	
func interupt_inspect():
	inspect_timer.stop()


func _on_defeat_zone_body_entered(body: Node2D) -> void:
	if (body is Player):
		if (PlayerManager.can_die):
			PlayerManager.emit_player_caught()
			get_node("/root/GameManager").load_level(2)
