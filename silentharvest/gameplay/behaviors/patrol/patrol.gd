class_name Patrol extends Node2D

@export var entity : Enemy


@export var loop_between_segments := false
@export var pause_at_end := true
@export var speed := 30.
@export var autostart := true

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
	
	entity.global_position = Vector2.ZERO
	add_entity_to_path_follow_node.call_deferred()
	
	entity.entering_patrol.connect(_on_entity_entering_patrol)
	entity.exiting_patrol.connect(_on_entity_exiting_patrol)
	
	# Scans its children in search of path2D
	for id in range(get_child_count()):
		var c = get_child(id)
		if (c is Path2D):
			path_count += 1
			
	_start_path()
	paused = !autostart
	
func start():
	paused = false
	
func pause():
	paused = true
	
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
	
	path_follow_node.progress += speed * delta * step
	
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
			
	if (state % 2 == 1): #path
		_start_path((state-1) / 2)
	else: #poi
		_play_entity_poi(state / 2)
		
func _start_path(path_id := 0):
	paused = false
	just_started = true
	_change_patrol_segment(path_id)

func _play_entity_poi(id := 0):
	paused = true
	entity.play_poi(id)

func on_entity_finished_poi():
	_next_state()

func _on_entity_entering_patrol():
	start()
	
func _on_entity_exiting_patrol():
	pause()
