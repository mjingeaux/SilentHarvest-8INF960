class_name EnemyStateInspect extends EnemyState

@export var state_name : String = "INSPECT"

@export var anim_name : String = "idle"

@export_category("AI")
@export var after_inspect_state : EnemyState

var _return_state : EnemyState
@onready var inspect_timer: Timer = $InspectTimer

## What happens when we initialize this state ?
func init() -> void:
	enemy.inspect_finished.connect(_end_state)

## What happens when the enemy enters this state ?
func enter() -> void:
	super()
	enemy.update_animation(anim_name) 
	enemy.velocity = Vector2.ZERO
	enemy.play_poi_inspect()
	_return_state = self

## What happens when the enemy exits this state ?
func exit() -> void:
	super()
	enemy.interupt_inspect()

## What happens during the _process update of this state ?
func process(_delta : float) -> EnemyState:
	return _return_state

func _end_state():
	if (enemy.lst_suspicious_point.is_empty()):
		_return_state = after_inspect_state
		if (after_inspect_state is EnemyStateGoto):
			after_inspect_state.destination = enemy.patrol_restart_pos
	else:
		enemy.inspect_next_point()
	
