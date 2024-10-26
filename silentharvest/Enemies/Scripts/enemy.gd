class_name Enemy extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var state_machine : EnemyStateMachine = $EnemyStateMachine

func _ready():
	state_machine.initialize(self)
	pass

func _process(delta):
	pass


func _physics_process(delta: float) -> void:
	move_and_slide()

func update_animation(anim_name : String):
	pass
