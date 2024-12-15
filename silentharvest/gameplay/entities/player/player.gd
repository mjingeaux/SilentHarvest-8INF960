class_name Player extends CharacterBody2D 

const SPEED = 150
const ACCELERATION = 15
const CROUCH_SPEED = 40
const CROUCH_ACCELERATION = 4
var LAST_DIRECTION = 0
@onready var animation = $AnimationPlayer
@onready var noise_emitter = $NoiseEmitter
@onready var noise_emitter_sneak: NoiseEmitter = $NoiseEmitterSneak
@onready var grass_sound: AudioStreamPlayer = $GrassSound
@onready var grass_sound_slow: AudioStreamPlayer = $GrassSoundSlow
@onready var sound_drop_item: AudioStreamPlayer = $DropItem

func crouching_movement(direction: Vector2) -> void:
	velocity.x = move_toward(velocity.x, direction.x * CROUCH_SPEED, CROUCH_ACCELERATION)
	velocity.y = move_toward(velocity.y, direction.y * CROUCH_SPEED, CROUCH_ACCELERATION)
	if (velocity.length() > CROUCH_SPEED):
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

func _physics_process(delta: float) -> void: # switch to _process
	var direction = Input.get_vector("left", "right","up","down")
	if(Input.is_action_pressed("crouch")):
		crouching_movement(direction)
		crouching_animation()
		if (velocity != Vector2.ZERO):
			noise_emitter_sneak.noise_update(delta)
			
			if (!grass_sound_slow.playing):
				grass_sound.stop()
				grass_sound_slow.play()
		else:
			grass_sound_slow.stop()
			grass_sound.stop()
		
	else:
		walking_movement(direction)
		walking_animation()
		if (velocity != Vector2.ZERO):
			noise_emitter.noise_update(delta)
			
			if (!grass_sound.playing):
				grass_sound.play()
				grass_sound_slow.stop()
		else:
			grass_sound_slow.stop()
			grass_sound.stop()

	move_and_slide()
