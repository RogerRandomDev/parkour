extends AbilityActionResource


const motionMesh=preload("res://Components/Abilities/KnockBackAbility/KnockBackMotionMesh.tres")
const motionParticleMat=preload("res://Components/Abilities/KnockBackAbility/KnockBackMotion.tres")


var travelVector:Vector3
var travelDistance:float

func loadAbility()->void:
	var s=root.get_node("CollisionShape3D").shape.duplicate()
	s.height-=0.05
	s.radius-=0.025
	
	setShape(s)

func trigger():
	setShapeTransform(root.global_transform)
	
	
	var tween:Tween=root.create_tween()
	
	var cam=root.getCamera()
	#player only
	#updates the camera fov to make it have more "IMPACT" when teleporting
	if cam:
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(cam,"fov",cam.fov*0.5,0.0625)
		tween.tween_property(cam,"fov",cam.fov,0.5)
		
	var model_rotation=root.get_node("Model").global_rotation
	var camera_rotation=root.get_node("CameraArm").global_rotation
	var modifier= -Vector3(sin(camera_rotation.y),sin(-camera_rotation.x),cos(camera_rotation.y))
	abilityArea.motion=10*modifier
	var dat:=space_state.cast_motion(abilityArea)
	root.moveTo(abilityArea.motion*dat[0]+abilityArea.transform.origin)
	travelVector=abilityArea.motion
	travelDistance=dat[0]
	root.velocity+=abilityArea.motion
	
	
	loadAbilityVisuals()



func loadAbilityVisuals()->void:
	var particles=GPUParticles3D.new()
	particles.draw_pass_1=motionMesh
	particles.process_material=motionParticleMat
	particles.amount=max(int(256*travelDistance),1)
	particles.one_shot=true
	particles.lifetime=3
	particles.visibility_aabb=AABB(Vector3(-21.256,-2.987,-2.941),Vector3(42.627,8.428,6.963))
	particles.explosiveness=1.0
	particles.process_material.emission_box_extents = Vector3(5*travelDistance,1,0.5)
	particles.process_priority=126
	root.get_tree().current_scene.add_child(particles)
	particles.global_position=root.global_position-travelVector*0.5
	particles.global_rotation=root.get_node("CameraArm").global_rotation
	particles.global_rotation=Vector3(0.0,particles.global_rotation.y+1.5708,particles.global_rotation.x)
	await root.get_tree().create_timer(3).timeout
	particles.queue_free()
