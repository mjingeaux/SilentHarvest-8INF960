extends NavigationRegion2D

var new_navigation_polygon: NavigationPolygon = get_navigation_polygon()
var geometry_data: NavigationMeshSourceGeometryData2D = NavigationMeshSourceGeometryData2D.new()

func _ready():
	pass
	parse_2d_collisionshapes(self)
	NavigationServer2D.bake_from_source_geometry_data(new_navigation_polygon, geometry_data);
	#new_navigation_polygon.make_polygons_from_outlines()
	#set_navigation_polygon(new_navigation_polygon)

func parse_2d_collisionshapes(root_node: Node2D):
	for node in get_parent().get_node("LstProp").get_children():
		if node is BaseProp:
			var area : CollisionPolygon2D = node.get_node("BlockingArea")
			var collisionpolygon_transform: Transform2D = area.get_global_transform()
			var collisionpolygon: PackedVector2Array = area.polygon
			var cp = collisionpolygon_transform * collisionpolygon
			geometry_data.add_obstruction_outline(cp)
			#new_navigation_polygon.add_outline(cp)
