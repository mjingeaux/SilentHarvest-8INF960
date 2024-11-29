class_name EnemyStateGoto extends EnemyState

@export var state_name : String = "GOTO"

@export var anim_name : String = "chase"

@export_category("AI")
@export var destination := Vector2(0, 0)
@export var after_goto_state : EnemyState
@export var goto_speed : float = 70.0
var navigation_agent : NavigationAgent2D
var next_path_pos : Vector2

## What happens when we initialize this state ?
func init() -> void:
	pass
	

## What happens when the enemy enters this state ?
func enter() -> void:
	super()
	if (after_goto_state.state_name == "INSPECT"):
		enemy.update_animation("?", true)
	navigation_agent.target_position = destination
	

## What happens when the enemy exits this state ?
func exit() -> void:
	super()
	enemy.update_animation("?", false)

func physics_process(delta: float) -> void:
	if (navigation_agent.is_navigation_finished()):
		return
	next_path_pos = navigation_agent.get_next_path_position()

## What happens during the _process update of this state ?
func process(_delta : float) -> EnemyState:
	enemy.velocity = next_path_pos - enemy.global_position
	enemy.match_direction_to_displacement()
	if (enemy.global_position.distance_squared_to(destination) < 3.):
		enemy.global_position = destination
		return after_goto_state
	else:
		enemy.velocity = enemy.velocity.normalized() * goto_speed
	return null
	
func goto(global_pos : Vector2):
	destination = global_pos
	state_machine.change_state(self)
