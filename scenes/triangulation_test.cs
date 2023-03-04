using Godot;
using System;

using TriangleNet.Geometry;
using TriangleNet.IO;
using TriangleNet.Meshing;

public partial class triangulation_test : Node2D
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		var p = new Polygon();

		// Add the outer box contour with boundary marker 1.
		p.Add(new Contour(new Vertex[9]
		{
			new Vertex(0.0, 0.0, 1),
			new Vertex(3.0, 0.0, 1),
			new Vertex(3.0, 1.0, 1),
			new Vertex(0.0, 1.0, 1),
			new Vertex(2.0, 1.0, 1),
			new Vertex(2.0, 4.0, 1),
			new Vertex(1.0, 4.0, 1),
			new Vertex(1.0, 1.0, 1),
			new Vertex(0.0, 1.0, 1)
		}, 1));

		var options = new ConstraintOptions() { ConformingDelaunay = true };
		var quality = new QualityOptions() { MinimumAngle = 25 };

		// Triangulate the polygon
		var mesh = p.Triangulate(options, quality);


		var meshInst = GetNode<MeshInstance2D>("mesh");

		var st = new SurfaceTool();

		st.Begin(Mesh.PrimitiveType.Triangles);
		foreach (var t in mesh.Triangles)
		{
			for (int i = 0; i < 3; i++)
			{
				var ve = t.GetVertex(i);
				st.AddVertex(new Vector3((float)ve[0], (float)ve[1], 0.0f));
			}
			//st.Index();
		}

		meshInst.Mesh = st.Commit();
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
