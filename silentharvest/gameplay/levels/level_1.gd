class_name Level_1 extends BaseLevel

func _input(event: InputEvent) -> void:
	if (event.is_action("crouch") ):
		var space_state = get_world_2d().direct_space_state
		var _target = PlayerManager.player
		var query = PhysicsRayQueryParameters2D.create(Vector2(400, 400), _target.global_position)
		#query.exclude = [self, parent]
		query.collision_mask = 256
		query.collide_with_areas = true
		query.collide_with_areas
		var result = space_state.intersect_ray(query)
		if (!result.is_empty()):
			print("collision")
