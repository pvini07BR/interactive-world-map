@tool
extends StaticBody3D

signal radius_changed

@export_range(0, 6.371) var radius : float = 1.0:
	set(value):
		if radius != value:
			radius = value
			emit_signal("radius_changed", value)
			#$mesh.regenerate(radius, resolution)
		
@export_range(2, 120, 1, "or_greater") var resolution = 10:
	set(value):
		if resolution != value:
			resolution = value
			#$mesh.regenerate(radius, resolution)
			
@export var shader : Shader

#func _ready():
#	$mesh.regenerate(radius, resolution)
	
func point_to_coordinate(pointOnUnitSphere : Vector3) -> Vector2:
	var latitude : float = asin(pointOnUnitSphere.y)
	var longitude : float = atan2(pointOnUnitSphere.x, -pointOnUnitSphere.z)
	
	return Vector2(latitude, longitude)
	
func coordinate_to_point(coordinate : Vector2) -> Vector3:
	var latitude = deg_to_rad(coordinate.x)
	var longitude = deg_to_rad(-coordinate.y)
	
	var y : float = sin(latitude)
	var r : float = cos(latitude)
	var x : float = sin(longitude) * r
	var z : float = -cos(longitude) * r
	
	return Vector3(x, y, z) * radius
