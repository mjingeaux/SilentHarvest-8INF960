extends Node2D

const SKEW_TIME_INFLUENCE := .05
const MAX_SKEW := .07
const SKEW_SPEED := 1.5

var lstEntities : Array[CharacterBody2D]
var animTimeLeft : Array[float] = [0, 0, 0, 0]

@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
var bounds : RectangleShape2D

func _ready() -> void:
	bounds = collision_shape.shape

func _physics_process(delta: float) -> void:
	for entity in lstEntities:
		var speed : float = entity.velocity.length()
		if (speed != 0.):
			var layer_id = to_local(entity.global_position).y / bounds.get_rect().size.y * 4
			increase_layer_movement(delta * speed / 4, layer_id)
			
	for i in range(0, 4):
		var time = animTimeLeft[i]
		if (time > 0.):
			var layer : Sprite2D = get_child(i)
			
			var skew_strength = cubic_repartition(SKEW_TIME_INFLUENCE * time)
			skew_strength = skew_strength * 2 * MAX_SKEW - MAX_SKEW  # center around 0
			
			var skew_value = sin(time * SKEW_SPEED) * skew_strength
			layer.skew = skew_value if (i%2 == 0) else -skew_value
				
			#layer.offset.x = sin(time * 2) * .1
			animTimeLeft[i] -= delta
			
func cubic_repartition(x : float) -> float:
	var a = 1 - x
	return clampf(1 - x*x*x, 0., 1.)
			
func increase_layer_movement(value : float, layer_id : int):
	if (layer_id >= 0 && layer_id < 4):
		animTimeLeft[layer_id] += value

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body is CharacterBody2D):
		lstEntities.append(body)
		body.tall_grass_counter += 1

func _on_area_2d_body_exited(body: Node2D) -> void:
	if (body is CharacterBody2D):
		lstEntities.erase(body)
		body.tall_grass_counter -= 1
	

# a revoir
func _on_wind_timer_timeout() -> void:
	pass
	#var dice = randi_range(0, 10)
	#if (dice < 4):
		#increase_layer_movement(.6, dice)
