class_name EnemyState extends Node

## Stores a reference to the enemy that this states belong to
var enemy : Enemy
var state_machine : EnemyStateMachine

signal state_entered()
signal state_exited()

## What happens when we initialize this state ?
func init() -> void:
	pass
	

## What happens when the enemy enters this state ?
func enter() -> void:
	state_entered.emit()
	

## What happens when the enemy exits this state ?
func exit() -> void:
	state_exited.emit()
	
## What happens during the _process update of this state ?
func process(_delta : float) -> EnemyState:
	return null
	
