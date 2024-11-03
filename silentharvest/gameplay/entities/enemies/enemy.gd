class_name Enemy extends CharacterBody2D

signal direction_changed( _new_direction : Vector2)
signal enemy_damaged() #??
signal poi_finished()

signal entering_patrol()
signal exiting_patrol()

const DIR_4 = [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP]

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var player : Player

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D 
@onready var state_machine : EnemyStateMachine = $EnemyStateMachine
@onready var vision_area : VisionArea = $VisionArea

var first_state_entering := true


func _ready():
	state_machine.initialize(self)

func _process(delta):
	pass


func _physics_process(delta: float) -> void:
	move_and_slide()
	

func set_direction(_new_direction : Vector2) -> bool:
	direction = _new_direction
	if direction == Vector2.ZERO:
		return false
	var direction_id : int = int(round((direction + cardinal_direction * 0.1).angle()/TAU*DIR_4.size()))
	var new_dir = DIR_4[direction_id]
	if new_dir == cardinal_direction:
		return false
	
	cardinal_direction = new_dir
	direction_changed.emit(new_dir)
	#sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	return true
	
func update_animation(state : String) -> void:
	if state == "chase":
		var exclamation = preload("res://gameplay/entities/enemies/ExclamationMark.tscn").instantiate()
		add_child(exclamation)
		await get_tree().create_timer(0.5).timeout
		remove_child(exclamation)
	#animation_player.play(state+"_"+anim_direction())

func _on_idle_state_exited() -> void:
	exiting_patrol.emit()

func _on_idle_state_entered() -> void:
	if (first_state_entering):
		first_state_entering = false
		return
	entering_patrol.emit()

func anim_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"
		
func play_poi(poi_id : int):
	$POI_Timer_TEMP.start()
