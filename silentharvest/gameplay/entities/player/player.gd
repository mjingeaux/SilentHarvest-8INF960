class_name Player extends CharacterBody2D

const SPEED = 200
const ACCELERATION = 75
const CROUCH_SPEED = 80
const CROUCH_ACCELERATION = 40
@onready var animation = $AnimationPlayer

var inventory : Inventory

func crouching_movement(direction: Vector2) -> void:
	velocity.x = move_toward(velocity.x, direction.x * CROUCH_SPEED, CROUCH_ACCELERATION)
	velocity.y = move_toward(velocity.y, direction.y * CROUCH_SPEED, CROUCH_ACCELERATION)

func crouching_animation() -> void:
	if(velocity.x != 0 or velocity.y != 0):
		if(abs(velocity.x) < abs(velocity.y)):
			if(velocity.y > 0):
				animation.play("crouch_down")
			else:
				animation.play("crouch_up");
		else:
			if(velocity.x > 0):
				animation.play("crouch_right")
			else:
				animation.play("crouch_left");
	else:
		animation.play("crouch_idle_right")

func walking_movement(direction: Vector2) -> void:
	velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION)
	velocity.y = move_toward(velocity.y, direction.y * SPEED, ACCELERATION)

func walking_animation() -> void:
	if(velocity.x != 0 or velocity.y != 0):
		if(abs(velocity.x) < abs(velocity.y)):
			if(velocity.y > 0):
				animation.play("walk_down")
			else:
				animation.play("walk_up");
		else:
			if(velocity.x > 0):
				animation.play("walk_right")
			else:
				animation.play("walk_left");
	else:
		animation.play("idle_right")

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("left", "right","up","down")
	if(Input.is_action_pressed("crouch")):
		crouching_movement(direction)
		crouching_animation()
	else:
		walking_movement(direction)
		walking_animation()

	move_and_slide()
