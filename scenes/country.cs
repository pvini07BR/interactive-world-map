using Godot;
using System;

using TriangleNet.Geometry;
using TriangleNet.IO;
using TriangleNet.Meshing;

public partial class country : Area3D
{
	[Export]
	public String formalName;

	[Export]
	public String acronym;

	[Export]
	public Texture flag;

	[Export]
	public Color color = Colors.White;

	[Export]
	public Color outlineColor = Colors.Black;

	[Export]
	public bool extrudeMesh = true;

	[Export]
	public float height = 0.25f;

	Node meshes;
	Node outlineMeshes;
	Node visibilityNotifiers;
	int meshesAdded = 0;

	public override void _Ready()
	{
		meshes = GetNode<Node>("meshes");
		outlineMeshes = GetNode<Node>("outlineMeshes");
		visibilityNotifiers = GetNode<Node>("visibilityNotifiers");

		foreach (VisibleOnScreenNotifier3D child in visibilityNotifiers.GetChildren())
		{
			string count = child.Name.ToString();

			MeshInstance3D meshInst = meshes.GetNode<MeshInstance3D>(count);
			MeshInstance3D outlineMeshInst = outlineMeshes.GetNode<MeshInstance3D>(count);

			child.ScreenEntered += () => onScreenEntered(meshInst, outlineMeshInst);
			child.ScreenExited += () => onScreenExited(meshInst, outlineMeshInst);
		}
	}

	public void add_country_mesh(Vector3[] vertices, Vector2 midPoint, Vector2 size)
	{
		// Generate Mesh
		meshesAdded += 1;

		var p = new Polygon();

		var v = new TriangleNet.Geometry.Vertex[vertices.Length];
		
		for (int i = 0; i < vertices.Length; i++)
		{
			v[i] = new Vertex(vertices[i].X, vertices[i].Z, 1);
		}

		p.Add(new Contour(v, 1), false);

		var options = new ConstraintOptions() { ConformingDelaunay = true };
		var quality = new QualityOptions() { MinimumAngle = 25 };

		// Triangulate the polygon
		var mesh = p.Triangulate(options, quality);

		var meshInst = new MeshInstance3D();
		meshInst.CastShadow = GeometryInstance3D.ShadowCastingSetting.Off;

		var material = new StandardMaterial3D();
		material.AlbedoColor = color;
		//material.CullMode = BaseMaterial3D.CullModeEnum.Disabled;

		meshInst.MaterialOverride = material;

		var st = new SurfaceTool();

		st.Begin(Mesh.PrimitiveType.Triangles);
		foreach (var t in mesh.Triangles)
		{
			for (int i = 0; i < 3; i++)
			{
				var ve = t.GetVertex(i);
				st.SetNormal(Vector3.Up);
				st.AddVertex(new Vector3((float)ve.X, height, (float)ve.Y));
			}
		}

		// Extrude the mesh
		//for (int i = 0; i < vertices.Length; i+=2)
		if (extrudeMesh)
		{
			foreach (var s in mesh.Segments)
			{
				var point1 = new Vector2((float)s.GetVertex(0).X, (float)s.GetVertex(0).Y);
				var point2 = new Vector2((float)s.GetVertex(1).X, (float)s.GetVertex(1).Y);

				var point1_3D = new Vector3(point1.X, 0.0f, point1.Y);
				var point2_3D = new Vector3(point2.X, 0.0f, point2.Y);
				var midPoint_3D = new Vector3(midPoint.X, 0.0f, midPoint.Y);

				var distFromCenter = point1_3D - midPoint_3D;
				var segmentLength = point2_3D - point1_3D;

				var cross = distFromCenter.Cross(segmentLength);

				if (cross.Y > 0.0f)
				{
					var triNormal1 = get_triangle_normal(new Vector3(point2.X, height, point2.Y), new Vector3(point2.X, 0.0f, point2.Y), new Vector3(point1.X, 0.0f, point1.Y));
					st.SetNormal(triNormal1);
					st.AddVertex(new Vector3(point2.X, height, point2.Y));
					st.SetNormal(triNormal1);
					st.AddVertex(new Vector3(point2.X, 0.0f, point2.Y));
					st.SetNormal(triNormal1);
					st.AddVertex(new Vector3(point1.X, 0.0f, point1.Y));
					
					var triNormal2 = get_triangle_normal(new Vector3(point1.X, 0.0f, point1.Y), new Vector3(point1.X, height, point1.Y), new Vector3(point2.X, height, point2.Y));
					st.SetNormal(triNormal2);
					st.AddVertex(new Vector3(point1.X, 0.0f, point1.Y));
					st.SetNormal(triNormal2);
					st.AddVertex(new Vector3(point1.X, height, point1.Y));
					st.SetNormal(triNormal2);
					st.AddVertex(new Vector3(point2.X, height, point2.Y));
				}
				else if (cross.Y < 0.0f)
				{
					var triNormal1_2 = get_triangle_normal(new Vector3(point1.X, 0.0f, point1.Y), new Vector3(point2.X, 0.0f, point2.Y), new Vector3(point2.X, height, point2.Y));
					st.SetNormal(triNormal1_2);
					st.AddVertex(new Vector3(point1.X, 0.0f, point1.Y));
					st.SetNormal(triNormal1_2);
					st.AddVertex(new Vector3(point2.X, 0.0f, point2.Y));
					st.SetNormal(triNormal1_2);
					st.AddVertex(new Vector3(point2.X, height, point2.Y));
					
					var triNormal2_2 = get_triangle_normal(new Vector3(point2.X, height, point2.Y), new Vector3(point1.X, height, point1.Y), new Vector3(point1.X, 0.0f, point1.Y));
					st.SetNormal(triNormal2_2);
					st.AddVertex(new Vector3(point2.X, height, point2.Y));
					st.SetNormal(triNormal2_2);
					st.AddVertex(new Vector3(point1.X, height, point1.Y));
					st.SetNormal(triNormal2_2);
					st.AddVertex(new Vector3(point1.X, 0.0f, point1.Y));
				}
				/*
				Vector2 point1 = new Vector2();
				Vector2 point2 = new Vector2();

				if ((i+1) < vertices.Length)
				{
					point1 = new Vector2(vertices[i].X, vertices[i].Y);
					point2 = new Vector2(vertices[i+1].X, vertices[i+1].Y);
				}
				else if ((i+1) > vertices.Length)
				{
					point1 = new Vector2(vertices[i].X, vertices[i].Y);
					point2 = new Vector2(vertices[0].X, vertices[0].Y);
				}

				var triNormal1 = get_triangle_normal(new Vector3(point2.X, height, point2.Y), new Vector3(point2.X, 0.0f, point2.Y), new Vector3(point1.X, 0.0f, point1.Y));
				st.SetNormal(triNormal1);
				st.AddVertex(new Vector3(point2.X, height, point2.Y));
				st.SetNormal(triNormal1);
				st.AddVertex(new Vector3(point2.X, 0.0f, point2.Y));
				st.SetNormal(triNormal1);
				st.AddVertex(new Vector3(point1.X, 0.0f, point1.Y));
				
				var triNormal2 = get_triangle_normal(new Vector3(point1.X, 0.0f, point1.Y), new Vector3(point1.X, height, point1.Y), new Vector3(point2.X, height, point2.Y));
				st.SetNormal(triNormal2);
				st.AddVertex(new Vector3(point1.X, 0.0f, point1.Y));
				st.SetNormal(triNormal2);
				st.AddVertex(new Vector3(point1.X, height, point1.Y));
				st.SetNormal(triNormal2);
				st.AddVertex(new Vector3(point2.X, height, point2.Y));
				*/
			}
		}

		st.Index();
		meshInst.Mesh = st.Commit();
		meshes.CallDeferred("add_child", meshInst);
		meshInst.Name = new StringName(meshesAdded.ToString());
		meshInst.Visible = false;

		// Create collision

		var newCol = new CollisionShape3D();
		newCol.Shape = meshInst.Mesh.CreateTrimeshShape();
		CallDeferred("add_child", newCol);
		newCol.Name = new StringName(meshesAdded.ToString());

		// Create outline
		var ost = new SurfaceTool();
		ost.Begin(Mesh.PrimitiveType.LineStrip);
		for (int i = 0; i < vertices.Length; i++)
		{
			var uh = vertices[i];
			uh.Y = height + 0.005f;
			ost.AddVertex(uh);
		}

		var outlineMeshInst = new MeshInstance3D();
		outlineMeshInst.CastShadow = GeometryInstance3D.ShadowCastingSetting.Off;
		outlineMeshInst.Mesh = ost.Commit();

		var outlineMat = new StandardMaterial3D();
		outlineMat.AlbedoColor = outlineColor;

		outlineMeshInst.MaterialOverride = outlineMat;

		outlineMeshes.CallDeferred("add_child", outlineMeshInst);
		outlineMeshInst.Name = new StringName(meshesAdded.ToString());
		outlineMeshInst.Visible = false;

		// create the visibility notifier
		var vn = new VisibleOnScreenNotifier3D();
		vn.Aabb = new Aabb(new Vector3(-(size.X/2), -0.05f, -(size.Y/2)), new Vector3(size.X, height, size.Y));
		vn.Position = new Vector3(midPoint.X, height/2.0f, midPoint.Y);
		vn.ScreenEntered += () => onScreenEntered(meshInst, outlineMeshInst);
		vn.ScreenExited += () => onScreenExited(meshInst, outlineMeshInst);
		
		visibilityNotifiers.CallDeferred("add_child", vn);
		vn.Name = new StringName(meshesAdded.ToString());

		/*

		var mi = new MeshInstance3D();
		var m = new BoxMesh();
		var mt = new StandardMaterial3D();
		mt.Transparency = BaseMaterial3D.TransparencyEnum.Alpha;
		mt.AlbedoColor = new Color(0.0f, 1.0f, 0.0f, 0.5f);
		m.Size = vn.Aabb.Size;
		m.Material = mt;
		mi.Mesh = m;
		vn.AddChild(mi);
		*/
	}

	public void onScreenEntered(Node3D mesh, Node3D outlineMesh)
	{
		mesh.Visible = true;
		outlineMesh.Visible = true;
		mesh.ProcessMode = ProcessModeEnum.Inherit;
		outlineMesh.ProcessMode = ProcessModeEnum.Inherit;
	}

	public void onScreenExited(Node3D mesh, Node3D outlineMesh)
	{
		mesh.Visible = false;
		outlineMesh.Visible = false;
		mesh.ProcessMode = ProcessModeEnum.Disabled;
		outlineMesh.ProcessMode = ProcessModeEnum.Disabled;
	}

	public void setColor(Color _color)
	{
		foreach (var child in meshes.GetChildren())
		{
			var cName = child.GetPath();
			var c = GetNode<MeshInstance3D>(cName);
			var mat = (StandardMaterial3D)c.MaterialOverride;
			mat.AlbedoColor = _color;
			c.MaterialOverride = mat;
		}
	}

	public void setOutlineColor(Color _color)
	{
		foreach (var child in outlineMeshes.GetChildren())
		{
			var cName = child.GetPath();
			var c = GetNode<MeshInstance3D>(cName);
			var mat = (StandardMaterial3D)c.MaterialOverride;
			mat.AlbedoColor = _color;
			c.MaterialOverride = mat;
		}
	}

	public Vector3 get_triangle_normal(Vector3 a, Vector3 b, Vector3 c)
	{
		//# find the surface normal given 3 vertices
		var side1 = b - a;
		var side2 = c - a;
		var normal = side2.Cross(side1);
		return normal.Normalized();
	}
}
