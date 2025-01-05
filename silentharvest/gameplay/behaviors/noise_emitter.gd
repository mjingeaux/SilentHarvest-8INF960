class_name NoiseEmitter extends Area2D

@onready var collision_shape : CollisionShape2D = $CollisionShape2D
var zone_radius : float

@export_range(0., 3., .1) var intensity = .5

var _lst_recepter_in_range : Array[Enemy]

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var shape = collision_shape.shape
	if (shape is CircleShape2D):
		zone_radius = shape.radius
	else:
		printerr("La shape associé au noise emitter n'est pas de type CircleShape2D")
	
func noise_update(delta : float, mult := 1.):
	for recepter in _lst_recepter_in_range:
		var dist := 1. - (recepter.global_position - global_position).length() / zone_radius
		dist *= dist #change distance impact to quadratic
		
		recepter.hear_noise(dist * intensity * mult, delta)
	
func _on_body_entered(body : Node2D):
	if (body is Enemy):
		_lst_recepter_in_range.append(body)
	
func _on_body_exited(body : Node2D):
	if (body is Enemy):
		_lst_recepter_in_range.erase(body)
		
