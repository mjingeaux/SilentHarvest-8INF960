class_name EnemyStateIdle extends EnemyState

@export var anim_name : String = "idle"

@export_category("AI")
@export var state_duration_min : float = 0.5
@export var state_duration_max : float = 1.5
@export var after_idle_state : EnemyState

## What happens when we initialize this state ?
func init() -> void:
	pass
	

## What happens when the enemy enters this state ?
func enter() -> void:
	super()
	enemy.velocity = Vector2.ZERO
	enemy.update_animation(anim_name) 
	

## What happens when the enemy exits this state ?
func exit() -> void:
	super()
	
## What happens during the _process update of this state ?
func process(_delta : float) -> EnemyState:
	return after_idle_state
