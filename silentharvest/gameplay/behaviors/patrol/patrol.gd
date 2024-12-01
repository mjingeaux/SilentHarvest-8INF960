class_name Patrol extends Node2D

@export var entity : Enemy

@export_category("Patrol")
@export var loop_between_segments := false
@export var pause_at_end := true
@export var speed := 30.
@export var autostart := true
@export var single_point_patrol := false

@export_category("Points of Interest")
@export var lst_poi : Array[GlobalE.Epoi_type]

var path_follow_node : PathFollow2D
var path_count := 0

var paused = true
var just_started = false

var state := 1
var step := 1.

func _ready() -> void:
	path_follow_node = PathFollow2D.new()
	path_follow_node.loop = false
	path_follow_node.rotates = false
	path_follow_node.y_sort_enabled = true
	
	entity.global_position = Vector2.ZERO
	add_entity_to_path_follow_node.call_deferred()
	
	entity.entering_patrol.connect(_on_entity_entering_patrol)
	entity.exiting_patrol.connect(_on_entity_exiting_patrol)
	
	# Scans its children in search of path2D
	for id in range(get_child_count()):
		var c = get_child(id)
		if (c is Path2D):
			path_count += 1
			c.y_sort_enabled = true
			
	if (path_count == 1):
		var path : Path2D = get_child(0)
		if (path.curve.point_count == 1):
			single_point_patrol = true
	
	_start_path()
	paused = !autostart
	
	
func start():
	paused = false
	entity.poi_timer.paused = false
	
	
func pause():
	paused = true
	entity.poi_timer.paused = true
	entity.patrol_restart_pos = entity.global_position - entity.position
	
func add_entity_to_path_follow_node():
	if (entity.get_parent()):
		entity.get_parent().remove_child(entity)
	path_follow_node.add_child(entity)
	entity.poi_finished.connect(on_entity_finished_poi)
	
func _change_patrol_segment(path_id : int):
	var next_path : Path2D = get_child(path_id)
	var parent = path_follow_node.get_parent()
	if (parent):
		parent.remove_child(path_follow_node)
	next_path.add_child(path_follow_node)
	path_follow_node.progress_ratio = 0. if step == 1. else 1.

	
func _process(delta: float) -> void:
	if (paused ):
		return
	
	entity.match_direction_to_displacement()
	
	var prev_pos = entity.global_position
	path_follow_node.progress += speed * delta * step
	var vel = entity.global_position - prev_pos
	entity.velocity = vel
	
	if ((path_follow_node.progress_ratio >= 1. ||
	 path_follow_node.progress_ratio <= 0.) &&
	 !just_started):
		# patrol segment ended
		_next_state()
	else:
		just_started = false
		
func _next_state():
	state += step
	
	var min_state := 0 #included 
	var max_state := path_count * 2 #included
	
	if (!pause_at_end):
		min_state += 1
		
	if (!pause_at_end || loop_between_segments):
		max_state -= 1
	
	if (state < min_state ||
		state > max_state):
		if (loop_between_segments):
			state = posmod(state, max_state + 1) + min_state
		else:
			step = -step
			if (!pause_at_end):
				state = clampi(state, min_state, max_state)
			else:
					state = pingpong(state, max_state)
			
	if (_is_state_path()): #path
		_start_path((state-1) / 2)
	else: #poi
		_play_entity_poi(state / 2)
		
func _is_state_path() -> bool:
	return state % 2 == 1
		
func _start_path(path_id := 0):
	paused = false
	just_started = true
	_change_patrol_segment(path_id)

func _play_entity_poi(id := 0):
	paused = true
	entity.play_poi(_get_poi_type(id))
	
func _get_poi_type(id : int) -> GlobalE.Epoi_type:
	assert(id < lst_poi.size())
	return lst_poi[id]

func on_entity_finished_poi():
	_next_state()

func _on_entity_entering_patrol():
	if (_is_state_path()):
		start()
	else:
		entity.poi_timer.paused = false
		
	
func _on_entity_exiting_patrol():
	pause()
