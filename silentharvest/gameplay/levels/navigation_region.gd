extends NavigationRegion2D

var geometry_data: NavigationMeshSourceGeometryData2D = NavigationMeshSourceGeometryData2D.new()

func _ready():
	parse_2d_collisionshapes()
	var new_navigation_polygon: NavigationPolygon = get_navigation_polygon()
	NavigationServer2D.bake_from_source_geometry_data(new_navigation_polygon, geometry_data)
	navigation_polygon = new_navigation_polygon

func parse_2d_collisionshapes():
	for node in get_parent().get_node("LstProp").get_children():
		if node is BaseProp:
			var area : CollisionPolygon2D = node.get_node("BlockingArea")
			var collisionpolygon_transform: Transform2D = area.get_global_transform()
			var self_transform: Transform2D = get_global_transform()
			var collisionpolygon: PackedVector2Array = area.polygon
			
			# every component should remain positive
			# <=> coll_trans * self_trans.inverse() * collisionpoly
			var cp = collisionpolygon_transform * collisionpolygon * self_transform
			geometry_data.add_obstruction_outline(cp)
