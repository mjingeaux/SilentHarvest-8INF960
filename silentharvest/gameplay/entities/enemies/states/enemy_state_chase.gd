class_name EnemyStateChase extends EnemyState


@export var anim_name : String = "chase"
@export var chase_speed : float = 40.0
@export var turn_rate : float = 0.25


@export_category("AI")
@export var vision_area : VisionArea
@export var state_aggro_duration : float = 1.5
@export var next_state : EnemyState

var _timer : float = 0.0
var _can_see_player : bool = false
var _last_player_position : Vector2
@onready var _player : Player = PlayerManager.player


## What happens when we initialize this state ?
func init() -> void:
	if vision_area:
		vision_area.player_entered.connect(_on_player_enter)
		vision_area.player_exited.connect(_on_player_exit)
	pass
	

## What happens when the enemy enters this state ?
func enter() -> void:
	super()
	_timer = state_aggro_duration
	enemy.update_animation(anim_name) 
	

## What happens when the enemy exits this state ?
func exit() -> void:
	super()
	
## What happens during the _process update of this state ?
func process(_delta : float) -> EnemyState:
	#var new_dir : Vector2 = enemy.global_position.direction_to(PlayerManager.player.global_position)
	var new_dir_vect : Vector2 = (PlayerManager.player.global_position - enemy.global_position).normalized()
	var new_dir_angle : float = new_dir_vect.angle()
	enemy.velocity = new_dir_vect * chase_speed
	enemy.set_direction(rad_to_deg(new_dir_angle))
	
	#TODO perform a raycast here
	
	if _can_see_player == false:
		_timer -= _delta
		if _timer <= 0:
			return next_state
	else:
		_timer = state_aggro_duration
	return null
	
func _on_player_enter() -> void:
	_can_see_player = true
	state_machine.change_state(self)

func _on_player_exit() -> void:
	_can_see_player = false
