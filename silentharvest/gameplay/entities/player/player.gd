class_name Player extends CharacterBody2D 

const SPEED = 150
const ACCELERATION = 15
const CROUCH_SPEED = 40
const CROUCH_ACCELERATION = 4
const TALL_GRASS_SPEED_RATIO = .4
const TALL_GRASS_VOLUME = 1.5
var LAST_DIRECTION = 0

const GRASS_TERRAIN_ID = 1

@onready var animation = $AnimationPlayer
@onready var noise_emitter = $NoiseEmitter
@onready var noise_emitter_sneak: NoiseEmitter = $NoiseEmitterSneak

@onready var foot_step_sound: FootStepSound = $FootStepSound

@onready var sound_drop_item: AudioStreamPlayer = $DropItem
@onready var camera_2d: Camera2D = $Camera2D

const speed_on_volume_influence := 10.
var grass_sound_base_volume : float
var slow_grass_sound_base_volume : float
# indicates how many tall grass area the player is colliding with
# used as a c style boolean
var tall_grass_counter := 0 
var level : Level_1 : set = _set_level
var grass_tilemap : TileMapLayer

func crouching_movement(direction: Vector2) -> void:
	var max_speed = CROUCH_SPEED * (TALL_GRASS_SPEED_RATIO if tall_grass_counter else 1.)
	velocity.x = move_toward(velocity.x, direction.x * max_speed, CROUCH_ACCELERATION)
	velocity.y = move_toward(velocity.y, direction.y * max_speed, CROUCH_ACCELERATION)
	if (velocity.length() > CROUCH_SPEED):
		velocity.x = move_toward(velocity.x, direction.x * max_speed, CROUCH_ACCELERATION)
		velocity.y = move_toward(velocity.y, direction.y * max_speed, CROUCH_ACCELERATION)

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
	var max_speed = SPEED * (TALL_GRASS_SPEED_RATIO if tall_grass_counter else 1.)
	velocity.x = move_toward(velocity.x, direction.x * max_speed, ACCELERATION)
	velocity.y = move_toward(velocity.y, direction.y * max_speed, ACCELERATION)

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
		foot_step_sound.is_slow = true
	else:
		walking_movement(direction)
		walking_animation()
		foot_step_sound.is_slow = false
	move_and_slide()
	
	if (velocity != Vector2.ZERO):
		var noise = get_current_noise_volume(direction)
		
		if(Input.is_action_pressed("crouch")):
			noise_emitter_sneak.noise_update(delta, noise)
		else:
			noise_emitter.noise_update(delta, noise)
			
		foot_step_sound.set_current_volume(- (1 - noise) * speed_on_volume_influence)
		foot_step_sound.play()
	else:
		foot_step_sound.stop()
	
	if (get_soil_type() == GlobalE.Esoil_type.grass):
		foot_step_sound.terrain_type = GlobalEnum.Esoil_type.grass
	else:
		foot_step_sound.terrain_type = GlobalEnum.Esoil_type.dirt
		
func get_soil_type() -> GlobalE.Esoil_type:
	if (!is_instance_valid(grass_tilemap)):
		return GlobalE.Esoil_type.grass
	
	var local_coord = grass_tilemap.to_local(global_position)
	var map_coord := grass_tilemap.local_to_map(local_coord)
	#var tile_data := grass_tilemap.get_cell_tile_data(map_coord)
	var source_id := grass_tilemap.get_cell_source_id(map_coord)
	var atlas_coord := grass_tilemap.get_cell_atlas_coords(map_coord)
	#if (!tile_data):
		#return GlobalE.Esoil_type.grass
	#var grass_id := grass_tilemap.tile_set.get_terrain_name(0, 1)
	if (source_id == -1 || source_id == 2 || source_id == 4):
		return GlobalE.Esoil_type.dirt
	else:
		return GlobalE.Esoil_type.grass
		
	
func get_current_noise_volume(direction : Vector2) -> float:
	var noise = clampf(direction.length(), 0, 1)
	if (tall_grass_counter > 0):
		noise *= TALL_GRASS_VOLUME
	return noise
	
func _set_level(l : Level_1):
	level = l
	grass_tilemap = level.get_node("Grass")
