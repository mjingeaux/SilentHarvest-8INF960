class_name EnemyStateChase extends EnemyState

@export var state_name : String = "CHASE"

@export var anim_name : String = "chase"
@export var chase_speed : float = 120.0
@export var turn_rate : float = 0.25


@export_category("AI")
@export var vision_area : VisionArea
@export var state_aggro_duration : float = 1.5
@export var next_state : EnemyState

var _timer : float = 0.0
var _can_see_player : bool = false
var _start_chase := false
@onready var sound_hoey: AudioStreamPlayer = $Hoey
var navigation_agent : NavigationAgent2D


## What happens when we initialize this state ?
func init() -> void:
	if vision_area:
		vision_area.player_entered.connect(_on_player_enter)
		vision_area.player_exited.connect(_on_player_exit)
	

## What happens when the enemy enters this state ?
func enter() -> void:
	super()
	_start_chase = false
	_timer = state_aggro_duration
	enemy.update_animation("!", true) 
	enemy.vision_area.rotation_speed = VisionArea.Erotation_speed.fast
	await get_tree().create_timer(.3).timeout
	_start_chase = true
	enemy.is_listening_noise = false
	enemy.lst_suspicious_point.clear()
	sound_hoey.play()


## What happens when the enemy exits this state ?
func exit() -> void:
	super()
	enemy.update_animation("!", false) 
	enemy.update_animation("?", true) 
	enemy.vision_area.rotation_speed = VisionArea.Erotation_speed.default
	
func physics_process(_delta: float) -> void:
	if (_start_chase):
		navigation_agent.target_position = PlayerManager.player.global_position
		var direction_vec = enemy.global_position.direction_to(navigation_agent.get_next_path_position())
		enemy.velocity = direction_vec * chase_speed
	
## What happens during the _process update of this state ?
func process(_delta : float) -> EnemyState:
	if (_start_chase):
		var player_pos = PlayerManager.player.global_position
		var new_dir_vect : Vector2 = (player_pos - enemy.global_position)
		var new_dir_angle : float = new_dir_vect.angle()
		
		enemy.set_direction(rad_to_deg(new_dir_angle))
		
		if !_can_see_player:
			_timer -= _delta
			if _timer <= 0:
				enemy.add_suspicious_point(player_pos)
				
				#if (next_state is EnemyStateGoto):
					#next_state.destination = enemy.patrol_restart_pos
				#return next_state
		else:
			_timer = state_aggro_duration
	return null
	
func _on_player_enter() -> void:
	_can_see_player = true
	state_machine.change_state(self)

func _on_player_exit() -> void:
	_can_see_player = false
