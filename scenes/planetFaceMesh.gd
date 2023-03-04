extends MeshInstance3D
class_name PlanetMeshFace

@export var normal : Vector3

func regenerate_mesh(_resolution : float):
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	
	var vertex_array := PackedVector3Array()
	var uv_array := PackedVector2Array()
	var normal_array := PackedVector3Array()
	var index_array := PackedInt32Array()
	
	var resolution := _resolution
	
	var num_vertices : int = resolution * resolution
	var num_indices : int = (resolution-1) * (resolution-1) * 6
	
	normal_array.resize(num_vertices)
	uv_array.resize(num_vertices)
	vertex_array.resize(num_vertices)
	index_array.resize(num_indices)
	
	var tri_index : int = 0
	var axisA := Vector3(normal.y, normal.z, normal.x)
	var axisB : Vector3 = normal.cross(axisA)
	for y in range(resolution):
		for x in range(resolution):
			var i : int = x + y * resolution
			var percent := Vector2(x,y) / (resolution-1)
			var pointOnUnitCube : Vector3 = normal + (percent.x-0.5) * 2.0 * axisA + (percent.y-0.5) * 2.0 * axisB
			var pointOnUnitSphere := _point_on_cube_to_point_on_sphere(pointOnUnitCube)
			vertex_array[i] = pointOnUnitSphere
			uv_array[i] = pointOnSphereToUV(pointOnUnitSphere)
			
			if x != resolution-1 and y != resolution-1:
				index_array[tri_index+2] = i
				index_array[tri_index+1] = i+resolution+1
				index_array[tri_index] = i+resolution
				
				index_array[tri_index+5] = i
				index_array[tri_index+4] = i+1
				index_array[tri_index+3] = i+resolution+1
				tri_index += 6
				
	for a in range(0, index_array.size(), 3):
		var b : int = a + 1
		var c : int = a + 2
		var ab : Vector3 = vertex_array[index_array[b]] - vertex_array[index_array[a]]
		var bc : Vector3 = vertex_array[index_array[c]] - vertex_array[index_array[b]]
		var ca : Vector3 = vertex_array[index_array[a]] - vertex_array[index_array[c]]
		var cross_ab_bc : Vector3 = ab.cross(bc) * -1.0
		var cross_bc_ca : Vector3 = bc.cross(ca) * -1.0
		var cross_ca_ab : Vector3 = ca.cross(ab) * -1.0
		normal_array[index_array[a]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normal_array[index_array[b]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
		normal_array[index_array[c]] += cross_ab_bc + cross_bc_ca + cross_ca_ab
	for i in range(normal_array.size()):
		normal_array[i] = normal_array[i].normalized()
		
	arrays[Mesh.ARRAY_VERTEX] = vertex_array
	arrays[Mesh.ARRAY_NORMAL] = normal_array
	arrays[Mesh.ARRAY_TEX_UV] = uv_array
	arrays[Mesh.ARRAY_INDEX] = index_array
	
	call_deferred("_update_mesh", arrays)
	
func _update_mesh(arrays : Array):
	var _mesh := ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	self.mesh = _mesh
	
func _point_on_cube_to_point_on_sphere(p : Vector3) -> Vector3:
	var x2 := p.x * p.x
	var y2 := p.y * p.y
	var z2 := p.z * p.z
	var x := p.x * sqrt(1 - (y2 + z2) / 2 + (y2 * z2) / 3)
	var y := p.y * sqrt(1 - (z2 + x2) / 2 + (z2 * x2) / 3)
	var z := p.z * sqrt(1 - (x2 + y2) / 2 + (x2 * y2) / 3)
	return Vector3(x, y, z)
	
func pointOnSphereToUV(p : Vector3) -> Vector2:
	var pn := p.normalized()
	
	var longitude := atan2(pn.x, -pn.z)
	var latitude := asin(pn.y)
	
	var u := (longitude / PI + 1) / 2
	var v := latitude / PI + 0.5
	return Vector2(u, v)
