class_name Patrol extends Node2D

@export var entity : Enemy


@export var loop_between_segments := false
@export var pause_at_end := true
@export var speed := 100.

var path_follow_node : PathFollow2D
var path_count := 0

var reverse := 1.
var current_path_id := -1
var paused = true
var just_started = false
var current_path_lenth : float

func _ready() -> void:
	
	path_follow_node = PathFollow2D.new()
	path_follow_node.loop = false
	path_follow_node.rotates = false
	
	add_entity_to_path_follow_node.call_deferred()
	
	# Scans its children in search of path2D
	for id in range(get_child_count()):
		var c = get_child(id)
		if (c is Path2D):
			path_count += 1
			print(c.name, " detected ! (", id, ")")
			
	start_patrol()
	
func add_entity_to_path_follow_node():
	if (entity.get_parent()):
		entity.get_parent().remove_child(entity)
	path_follow_node.add_child(entity)
	entity.poi_finished.connect(on_entity_finished_poi)
		
func start_patrol():
	current_path_id = 0
	path_follow_node.progress_ratio = 0
	paused = false
	just_started = true
	change_patrol_segment()
	
func change_patrol_segment(id := 0):
	var next_path : Path2D = get_child(id)
	if (current_path_id != -1):
		get_child(current_path_id - reverse).remove_child(path_follow_node)
		next_path.add_child(path_follow_node)
	else:
		next_path.add_child(path_follow_node)
	current_path_id = id
	current_path_lenth = next_path.curve.get_baked_length()
	path_follow_node.progress_ratio = 0. if (reverse == 1.) else 1.
	
func play_entity_poi():
	paused = true
	var poi_id = get_current_poi()
	entity.play_poi(poi_id)

func get_current_poi() -> int:
	#here current path id is the middle of 2 poi (ie. ( currentPathId + 1) / 2)
	# and reverse's sign will determine which side's poi to choose.
	# (+1 is either completeted to 2, or neutralized to 0 by reverse's value)
	return (current_path_id * 2 + 1 + reverse) / 2
	
func _process(delta: float) -> void:
	if (!paused):
		path_follow_node.progress += speed * delta * reverse
		
		if ((path_follow_node.progress_ratio >= 1. ||
		 path_follow_node.progress_ratio <= 0.) &&
		 !just_started):
			# patrol segment ended
			
			var current_poi = get_current_poi()
			if (current_poi == 0 || current_poi >= path_count):
				#last patrol segment reached
				if (!loop_between_segments): #ping pong
					reverse = -reverse
					just_started = true
				if (pause_at_end):
					play_entity_poi()
			else:
				play_entity_poi()
				just_started = true
				
				
			current_path_id += reverse
			if (loop_between_segments):
				current_path_id %= path_count
			else:
				current_path_id = pingpong(current_path_id, path_count)
			change_patrol_segment(current_path_id)
		else:
			just_started = false

func on_entity_finished_poi():
	print("poi finished")
	paused = false
