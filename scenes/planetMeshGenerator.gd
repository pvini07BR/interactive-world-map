@tool
extends MeshInstance3D

signal finished_generating_meshes

func regenerate(radius : float, resolution : int):
	mesh = null
	var newMesh = ArrayMesh.new()
	var directions := [Vector3.UP, Vector3.DOWN, Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK]
	for i in range(directions.size()):
		newMesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _generate_face(directions[i], radius, resolution))
		match directions[i]:
			Vector3.UP:
				newMesh.surface_set_name(i, "Up")
			Vector3.DOWN:
				newMesh.surface_set_name(i, "Down")
			Vector3.LEFT:
				newMesh.surface_set_name(i, "Left")
			Vector3.RIGHT:
				newMesh.surface_set_name(i, "Right")
			Vector3.FORWARD:
				newMesh.surface_set_name(i, "Forward")
			Vector3.BACK:
				newMesh.surface_set_name(i, "Back")
			
	mesh = newMesh
	emit_signal("finished_generating_meshes", newMesh)
	
func _generate_face(normal : Vector3, radius : float, resolution : int):
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)

	var vertex_array := PackedVector3Array()
	var uv_array := PackedVector2Array()
	var normal_array := PackedVector3Array()
	var index_array := PackedInt32Array()
	
	var num_vertices : int = resolution * resolution
	var num_indices : int = (resolution-1) * (resolution-1) * 6
	
	normal_array.resize(num_vertices)
	uv_array.resize(num_vertices)
	vertex_array.resize(num_vertices)
	index_array.resize(num_indices)
	
	var tri_index := 0
	var axisA := Vector3(normal.y, normal.z, normal.x)
	var axisB : Vector3 = normal.cross(axisA)
	for y in range(resolution):
		for x in range(resolution):
			var i : int = x + y * resolution
			var percent := Vector2(x,y) / (resolution-1)
			var pointOnUnitCube : Vector3 = normal + (percent.x - 0.5) * 2.0 * axisA + (percent.y - 0.5) * 2.0 * axisB
			var pointOnUnitSphere : Vector3 = point_on_cube_to_point_on_sphere(pointOnUnitCube)
			vertex_array[i] = pointOnUnitSphere * radius
			uv_array[i] = point_on_sphere_to_uv(pointOnUnitSphere)
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
	
	return arrays

func point_on_cube_to_point_on_sphere(p : Vector3) -> Vector3:
	var x2 : float = pow(p.x, 2)
	var y2 : float = pow(p.y, 2)
	var z2 : float = pow(p.z, 2)
	
	var x : float = p.x * sqrt(1 - (y2 / 2) - (z2 / 2) + ((y2 * z2) / 3))
	var y : float = p.y * sqrt(1 - (z2 / 2) - (x2 / 2) + ((z2 * x2) / 3))
	var z : float = p.z * sqrt(1 - (x2 / 2) - (y2 / 2) + ((x2 * y2) / 3))
	
	return Vector3(x, y, z);
	
func point_on_sphere_to_uv(p : Vector3) -> Vector2:
	p = p.normalized()
	
	var longitude : float = -atan2(p.x, -p.z)
	var latitude : float = -asin(p.y)
	
	var u : float = (longitude / PI + 1) / 2
	var v : float = latitude / PI + 0.5
	
	return Vector2(u, v)
