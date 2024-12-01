class_name VisionArea extends Area2D


enum Erotation_speed{
	slow,
	medium,
	fast,
	instant,
	default = slow,
}
signal rotation_completed()
signal player_entered()
signal player_exited()

# progress [0, 1] per second
const SLOW_ROTATION 	= 1.3
const MEDIUM_ROTATION 	= 2.5
const FAST_ROTATION 	= 3.9

var angle_target_degree: float : set = _set_angle_target_degree
var rotation_speed : Erotation_speed = Erotation_speed.default


var _angle_from_degree: float
var is_rotating = false
var _rotation_progress : float # 0..1
var _target : Node2D
var _is_player_visible := false : set = _set_is_player_visible

@onready var _shape : CollisionPolygon2D = get_child(0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_enter)
	body_exited.connect(_on_body_exit)
	var p = get_parent()
	if p is Enemy:
		p.direction_changed.connect(_on_direction_change)
		
func _on_body_enter(_b : Node2D) -> void:
	if _b is Player:
		_target = _b
		#_raycast.enabled = true
		#player_entered.emit()
	
func _on_body_exit(_b : Node2D) -> void:
	if _b is Player:
		_target = null
		#_raycast.enabled = false
		#player_exited.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (is_rotating):
		_rotation_progress += delta * _get_rotation_speed()
		
		if (_rotation_progress >= 1.): 
			rotation_degrees = angle_target_degree
			is_rotating = false
			rotation_completed.emit()
		else:
			rotation = lerp_angle(deg_to_rad(_angle_from_degree), deg_to_rad(angle_target_degree), _rotation_progress)
		
	if (_target):
		_is_player_visible = _raycast_target()
	else:
		_is_player_visible = false
		
func _raycast_target():
	var targets = _target.get_node("VisibilityHotspots").get_children()
	var result: Dictionary
	for t in targets:
		var poly = _shape.global_transform * _shape.polygon
		if (Geometry2D.is_point_in_polygon(t.global_position, poly)):
			var parent = get_parent() as Node2D
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsRayQueryParameters2D.create(parent.global_position, t.global_position)
			query.exclude = [self, parent]
			query.collision_mask = 256
			query.collide_with_areas = true
			result = space_state.intersect_ray(query)
			if (!result.is_empty()):
				if (result.collider is Player):
					return true
	return false
	
func _set_is_player_visible(val : bool):
	if (val != _is_player_visible):
		_is_player_visible = val
		if (val):
			player_entered.emit()
		else:
			player_exited.emit()
	

func _get_rotation_speed():
	match rotation_speed:
		Erotation_speed.slow:
			return SLOW_ROTATION
			
		Erotation_speed.medium:
			return MEDIUM_ROTATION
			
		Erotation_speed.fast:
			return FAST_ROTATION
	return 9999.
	
func _set_angle_target_degree(new_degree_angle : float):
	if (new_degree_angle == angle_target_degree):
		return
		
	if (rotation_speed == Erotation_speed.instant):
		rotation_degrees = new_degree_angle
		rotation_completed.emit()
		return
		
	_angle_from_degree = rotation_degrees
	angle_target_degree = new_degree_angle
	is_rotating = true
	_rotation_progress = 0.

func _on_direction_change(new_direction : Vector2) -> void:
	match new_direction:
		Vector2.DOWN:
			rotation_degrees = 0
		Vector2.UP:
			rotation_degrees = 180
		Vector2.LEFT:
			rotation_degrees = 90
		Vector2.RIGHT:
			rotation_degrees = -90
		_:
			rotation_degrees = 0
	pass
