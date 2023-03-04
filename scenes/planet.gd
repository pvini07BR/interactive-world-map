extends Node3D

@export var resolution = 100.0

func _ready():
	#generateAll()
	pass
		
func generateAll():
	for child in get_children():
		if child.is_in_group("face"):
			var face := child as PlanetMeshFace
			face.regenerate_mesh(resolution)
		
func pointToCoordinate(pointOnUnitSphere : Vector3) -> Vector2:
	var latitude := asin(pointOnUnitSphere.y)
	var longitude := atan2(pointOnUnitSphere.x, -pointOnUnitSphere.z)
	return Vector2(latitude, longitude)
	
func coordinateToPoint(coordinate : Vector2) -> Vector3:
	var y := sin(coordinate.x)
	var r := cos(coordinate.x)
	var x := sin(coordinate.y) * r
	var z := -cos(coordinate.y) * r
	return Vector3(x, y, z)
