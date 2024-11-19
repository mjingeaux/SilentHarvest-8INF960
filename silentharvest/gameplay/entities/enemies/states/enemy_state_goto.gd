class_name EnemyStateGoto extends EnemyState

@export var anim_name : String = "chase"

@export_category("AI")
@export var destination := Vector2(0, 0)
@export var after_goto_state : EnemyState
@export var goto_speed : float = 40.0


## What happens when we initialize this state ?
func init() -> void:
	pass
	

## What happens when the enemy enters this state ?
func enter() -> void:
	super()
	enemy.update_animation(anim_name) 
	

## What happens when the enemy exits this state ?
func exit() -> void:
	super()

## What happens during the _process update of this state ?
func process(_delta : float) -> EnemyState:
	enemy.velocity = destination - enemy.global_position
	enemy.match_direction_to_displacement()
	if (enemy.velocity.length() < 3.):
		enemy.global_position = destination
		return after_goto_state
	else:
		enemy.velocity = enemy.velocity.normalized() * goto_speed
	return null
	
func goto(global_pos : Vector2):
	destination = global_pos
	state_machine.change_state(self)
