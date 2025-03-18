extends Node







func renderLine(from:Vector3,to:Vector3,lineMaterial:ORMMaterial3D)->MeshInstance3D:
	var outMesh=MeshInstance3D.new()
	var immediate:ImmediateMesh=ImmediateMesh.new()
	outMesh.cast_shadow=false
	immediate.surface_begin(Mesh.PRIMITIVE_LINES,lineMaterial)
	immediate.surface_add_vertex(Vector3.ZERO)
	immediate.surface_add_vertex(Vector3(0,0,1))
	immediate.surface_end()
	outMesh.mesh=immediate
	outMesh.look_at_from_position(from,to)
	get_tree().current_scene.add_child(outMesh)
	return outMesh
