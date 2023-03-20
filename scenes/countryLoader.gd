extends Node

@export var mapResolution : Vector2 = Vector2(5400, 2700)

@export_file("*.json") var countryDataFilePath : String = "res://assets/data/countries_data.json"
@export var countryMaterial : BaseMaterial3D

var loadedCountries := []

var thread : Thread
var mutex : Mutex

signal loading_countries_finished

func start_country_generation():
	mutex = Mutex.new()
	thread = Thread.new()
	thread.start(_generate_countries)
	#_generate_countries(radius)

func _generate_countries():
	mutex.lock()
	if get_child_count() > 0:
		for i in get_children():
			remove_child(i)
			i.queue_free()
	
	var jsonFile := FileAccess.open(countryDataFilePath, FileAccess.READ)
	if jsonFile == null:
		return
		
	var parsedJson = JSON.parse_string(jsonFile.get_as_text())
	if parsedJson == null:
		return
		
	for country in parsedJson["features"]:
		var c_name = country["properties"]["NAME_EN"]
#		var c_formalName = country["properties"]["FORMAL_EN"]
#		var c_acronym = country["properties"]["ADM0_A3_US"]
#		var c_flag = load("res://assets/images/flags/" + c_acronym + ".svg")
		
		var geometry = country["geometry"]
		var type = geometry["type"]

		var c_polygons := []
		
		for useless in geometry["coordinates"]:
			if type == "Polygon":
				var points := []
				for p in range(useless.size()):
					var point = useless[p]
					var coords = Vector2(point[1], point[0])
					var gp = coordinate_to_2d_point(mapResolution, coords)
					points.append(gp)
				#print(points.is_empty())
					
				#print("Single: " + str(points.front() == points.back()))
					
				c_polygons.append(PackedVector2Array(points))
				
			elif type == "MultiPolygon":
				for polygon in useless:
					var points := []
					for p in range(polygon.size()):
						var point = polygon[p]
						var coords = Vector2(point[1], point[0])
						var gp = coordinate_to_2d_point(mapResolution, coords)
						points.append(gp)
					#print(points.is_empty())
						
					#print("Multi: " + str(points.front() == points.back()))
					
					c_polygons.append(PackedVector2Array(points))

		var newCountry = {
			name = c_name,
			polygons = c_polygons
		}
		
		loadedCountries.append(newCountry)
		
	mutex.unlock()
		
	emit_signal("loading_countries_finished", loadedCountries)
	
func coordinate_to_2d_point(mapSize : Vector2, coordinate : Vector2) -> Vector2:
	var latitude = coordinate.x
	var longitude = coordinate.y
	
	var x : int = int((mapSize.x/360.0) * (180 + longitude))
	var y : int = int((mapSize.y/180.0) * (90 - latitude))
	return Vector2(x, y)
	
func coordinate_to_3d_point_on_sphere(coordinate : Vector2) -> Vector3:
	var latitude = deg_to_rad(coordinate.x)
	var longitude = deg_to_rad(-coordinate.y)
	
	var y : float = sin(latitude)
	var r : float = cos(latitude)
	var x : float = sin(longitude) * r
	var z : float = -cos(longitude) * r
	
	return Vector3(x, y, z)
	
func _exit_tree():
	if thread != null and thread.is_started():
		thread.wait_to_finish()

#func project_position(p : Vector3, radius : float) -> Vector3:
#	var raycast = RayCast3D.new()
#
#	raycast.position = p * (radius * 2)
#	raycast.target_position = raycast.position.direction_to(Vector3.ZERO)
#	#call_deferred("add_child", raycast)
#
#	var intersect = raycast.get_collision_point()
#	raycast.queue_free()
#
#	return intersect
#	var config := PhysicsRayQueryParameters3D.new()
#	config.from = p * (radius * 2)
#	config.to = Vector3.ZERO
#
#	var space = get_world_3d().direct_space_state
#	var result = space.intersect_ray(config)
#
#	if not result.is_empty():
#		return result.position
#	else:
#		return Vector3.ZERO
