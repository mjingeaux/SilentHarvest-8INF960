extends NavigationRegion2D

var new_navigation_polygon: NavigationPolygon = get_navigation_polygon()

func _ready():
	parse_2d_collisionshapes(self)
	new_navigation_polygon.make_polygons_from_outlines()
	set_navigation_polygon(new_navigation_polygon)

func parse_2d_collisionshapes(root_node: Node2D):
	for node in get_parent().get_node("LstProp").get_children():
		if node is BaseProp:
			var collision_polygon : CollisionPolygon2D = node.get_node("BlockingArea")
			var collisionpolygon_transform: Transform2D = collision_polygon.get_global_transform()
			var collisionpolygon: PackedVector2Array = collision_polygon.polygon

			var new_collision_outline: PackedVector2Array = collisionpolygon_transform * collisionpolygon

			new_navigation_polygon.add_outline(new_collision_outline)
