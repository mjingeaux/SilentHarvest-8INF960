class_name Player extends CharacterBody2D


const SPEED = 200
const ACCELERATION = 75
const CROUCH_SPEED = 40
const CROUCH_ACCELERATION = 20
var LAST_DIRECTION = 0
@onready var animation = $AnimationPlayer

func crouching_movement(direction: Vector2) -> void:
	velocity.x = move_toward(velocity.x, direction.x * CROUCH_SPEED, CROUCH_ACCELERATION)
	velocity.y = move_toward(velocity.y, direction.y * CROUCH_SPEED, CROUCH_ACCELERATION)

func crouching_animation() -> void:
	if(velocity.x != 0 or velocity.y != 0):
		if(abs(velocity.x) < abs(velocity.y)):
			if(velocity.y > 0):
				animation.play("crouch_down")
				LAST_DIRECTION = 1
			else:
				animation.play("crouch_up");
				LAST_DIRECTION = 3
		else:
			if(velocity.x > 0):
				animation.play("crouch_right")
				LAST_DIRECTION = 0
			else:
				animation.play("crouch_left");
				LAST_DIRECTION = 2
	else:
		if(LAST_DIRECTION == 0):
			animation.play("crouch_idle_right")
		elif(LAST_DIRECTION == 1):
			animation.play("crouch_idle_down")
		elif(LAST_DIRECTION == 2):
			animation.play("crouch_idle_left")
		elif(LAST_DIRECTION == 3):
			animation.play("crouch_idle_up")

func walking_movement(direction: Vector2) -> void:
	velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION)
	velocity.y = move_toward(velocity.y, direction.y * SPEED, ACCELERATION)

func walking_animation() -> void:
	if(velocity.x != 0 or velocity.y != 0):
		if(abs(velocity.x) < abs(velocity.y)):
			if(velocity.y > 0):
				animation.play("walk_down")
				LAST_DIRECTION = 1
			else:
				animation.play("walk_up");
				LAST_DIRECTION = 3
		else:
			if(velocity.x > 0):
				animation.play("walk_right")
				LAST_DIRECTION = 0
			else:
				animation.play("walk_left");
				LAST_DIRECTION = 2
	else:
		if(LAST_DIRECTION == 0):
			animation.play("idle_right")
		elif(LAST_DIRECTION == 1):
			animation.play("idle_down")
		elif(LAST_DIRECTION == 2):
			animation.play("idle_left")
		elif(LAST_DIRECTION == 3):
			animation.play("idle_up")

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("left", "right","up","down")
	if(Input.is_action_pressed("crouch")):
		crouching_movement(direction)
		crouching_animation()
	else:
		walking_movement(direction)
		walking_animation()

	move_and_slide()
