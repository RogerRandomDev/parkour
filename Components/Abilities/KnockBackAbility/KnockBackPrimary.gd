extends AbilityActionResource


const meshShader=preload("res://Components/Abilities/KnockBackAbility/knockBackAbility.gdshader")

func loadAbility()->void:
	var s=SphereShape3D.new()
	s.radius=6
	setShape(s)

func trigger():
	loadAbilityVisuals()
	await root.get_tree().create_timer(0.25).timeout
	setShapeTransform(root.global_transform)
	var targets=getEntitiesInRange()
	for target in targets:
		if target.get("mass")==null||target==root:continue
		var dir=target.global_position-root.global_position
		var dirDist=dir.length_squared()
		target.apply_central_impulse(dir.normalized()*max(5,5/(dirDist/5)))



func loadAbilityVisuals()->void:
	var mesh=MeshInstance3D.new()
	var meshShape=SphereMesh.new()
	meshShape.radius=3.0
	meshShape.height=6.0
	mesh.mesh=meshShape
	origin_node.add_child(mesh)
	
	
	var tween:Tween=mesh.create_tween()
	mesh.scale=Vector3.ZERO
	var meshEffect=ShaderMaterial.new()
	meshEffect.shader=meshShader
	mesh.mesh.surface_set_material(0,meshEffect)
	meshEffect.set_shader_parameter('rippleStrength',10.0)

	for i in range(0,6):
		var scale_of=float(i+1)/6
		#tween.tween_property(mesh,'scale',Vector3(scale_of,scale_of,scale_of),0.0)
		tween.tween_callback(func():
			mesh.scale=Vector3(scale_of,scale_of,scale_of)
			meshEffect.set_shader_parameter('rippleProgress',float(i+1)/6)
			)
		
		tween.tween_interval(0.0833333)
	tween.tween_callback(mesh.queue_free)
	
