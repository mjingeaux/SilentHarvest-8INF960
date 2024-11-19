class_name EnemyStateInspect extends EnemyState

@export var anim_name : String = "idle"

@export_category("AI")
@export var after_inspect_state : EnemyState


## What happens when we initialize this state ?
func init() -> void:
	pass
	

## What happens when the enemy enters this state ?
func enter() -> void:
	super()
	enemy.update_animation(anim_name) 
	enemy.velocity = Vector2.ZERO
	print("inspecting .... ")
	

## What happens when the enemy exits this state ?
func exit() -> void:
	super()

## What happens during the _process update of this state ?
func process(_delta : float) -> EnemyState:
	return self
