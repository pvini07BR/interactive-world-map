extends MeshInstance3D

func _ready():
	var st = SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	st.add_vertex(Vector3(0.0, 1.0, 0.0))
	st.add_vertex(Vector3(1.0, 1.0, 0.0))
	st.add_vertex(Vector3(1.0, 0.0, 0.0))
	
	st.add_vertex(Vector3(1.0, 0.0, 0.0))
	st.add_vertex(Vector3(0.0, 0.0, 0.0))
	st.add_vertex(Vector3(0.0, 1.0, 0.0))
	
	mesh = st.commit()
